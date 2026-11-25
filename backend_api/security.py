"""Contraseñas (Argon2) y sesiones (JWT)."""
import os
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pwdlib import PasswordHash
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Usuario

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")
if not SECRET_KEY or len(SECRET_KEY) < 32:
    raise RuntimeError(
        "Define SECRET_KEY (mínimo 32 caracteres) en el archivo .env"
    )

ALGORITHM = "HS256"
TOKEN_MINUTOS = int(os.getenv("TOKEN_MINUTOS", "60"))

# Argon2id con parámetros recomendados + sal aleatoria por contraseña.
password_hash = PasswordHash.recommended()

_bearer = HTTPBearer(auto_error=False)


def crear_token(usuario: Usuario) -> str:
    ahora = datetime.now(timezone.utc)
    payload = {
        "sub": str(usuario.id_usr),
        "tip": usuario.tip_usu,
        "iat": ahora,
        "exp": ahora + timedelta(minutes=TOKEN_MINUTOS),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def _usuario_desde_credenciales(
    cred: HTTPAuthorizationCredentials | None,
    db: Session,
) -> Usuario | None:
    if cred is None:
        return None
    try:
        datos = jwt.decode(cred.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        id_usr = int(datos["sub"])
    except (jwt.PyJWTError, KeyError, ValueError):
        return None
    return db.get(Usuario, id_usr)


def usuario_actual(
    cred: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(obtener_sesion),
) -> Usuario:
    usuario = _usuario_desde_credenciales(cred, db)
    if usuario is None:
        raise HTTPException(
            status_code=401,
            detail="Sesión inválida o expirada. Inicia sesión de nuevo.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return usuario


def usuario_opcional(
    cred: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(obtener_sesion),
) -> Usuario | None:
    return _usuario_desde_credenciales(cred, db)


def solo_admin(usuario: Usuario = Depends(usuario_actual)) -> Usuario:
    if usuario.tip_usu != 1:
        raise HTTPException(
            status_code=403,
            detail="Solo un administrador puede realizar esta acción",
        )
    return usuario
