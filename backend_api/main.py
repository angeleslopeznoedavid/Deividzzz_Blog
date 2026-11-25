from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from database import obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    LoginRequest,
    LoginRespuesta,
    BlogCrear,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
)
from security import (
    password_hash,
    crear_token,
    usuario_actual,
    usuario_opcional,
    solo_admin,
)

app = FastAPI(title="API de aplicación móvil - Blog")

# CORS solo para desarrollo web (Flutter en Chrome). La app móvil no lo usa.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}


# ----------------------------------------------------------------- LOGIN
def _password_valida(password: str, hash_guardado: str) -> bool:
    """Verifica la contraseña; un hash inválido (datos de prueba) = rechazo."""
    try:
        return password_hash.verify(password, hash_guardado)
    except Exception:
        return False


@app.post("/login", response_model=LoginRespuesta)
def iniciar_sesion(datos: LoginRequest, db: Session = Depends(obtener_sesion)):
    correo = datos.mail.strip().lower()
    usuario = db.scalar(select(Usuario).where(Usuario.mail == correo))

    # Mismo mensaje para correo inexistente y contraseña errónea
    # (evita enumerar cuentas).
    if usuario is None or not _password_valida(datos.password, usuario.pass_hash):
        raise HTTPException(
            status_code=401, detail="Correo o contraseña incorrectos"
        )

    return LoginRespuesta(
        id_usr=usuario.id_usr,
        nom_usr=usuario.nom_usr,
        mail=usuario.mail,
        dir_usr=usuario.dir_usr,
        tip_usu=usuario.tip_usu,
        access_token=crear_token(usuario),
    )


# -------------------------------------------------------------- USUARIOS
@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(
    db: Session = Depends(obtener_sesion),
    _admin: Usuario = Depends(solo_admin),
):
    return db.scalars(select(Usuario).order_by(Usuario.id_usr)).all()


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
    quien: Usuario | None = Depends(usuario_opcional),
):
    # Registro público => siempre usuario general. Solo un administrador
    # autenticado puede crear otras cuentas de administrador.
    es_admin = quien is not None and quien.tip_usu == 1
    tipo = datos.tip_usu if es_admin and datos.tip_usu in (1, 2) else 2

    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        pass_hash=password_hash.hash(datos.password),
        dir_usr=datos.dir_usr,
        tip_usu=tipo,
    )
    db.add(usuario)
    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="El correo ya está registrado")
    return usuario


@app.put("/usuarios/{usuario_id}", response_model=UsuarioRespuesta)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
    quien: Usuario = Depends(usuario_actual),
):
    if quien.id_usr != usuario_id and quien.tip_usu != 1:
        raise HTTPException(status_code=403, detail="No puedes editar a otro usuario")

    usuario = db.get(Usuario, usuario_id)
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.dir_usr = datos.dir_usr
    # Solo un administrador puede cambiar roles.
    if quien.tip_usu == 1 and datos.tip_usu in (1, 2):
        usuario.tip_usu = datos.tip_usu

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="El correo ya está registrado")
    return usuario


@app.delete("/usuarios/{usuario_id}")
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
    admin: Usuario = Depends(solo_admin),
):
    if admin.id_usr == usuario_id:
        raise HTTPException(
            status_code=400, detail="No puedes eliminar tu propia cuenta"
        )
    usuario = db.get(Usuario, usuario_id)
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    db.delete(usuario)
    db.commit()
    return {"mensaje": "Usuario eliminado"}


# ------------------------------------------------------------------ BLOG
@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(
    db: Session = Depends(obtener_sesion),
    _u: Usuario = Depends(usuario_actual),
):
    return db.scalars(select(Blog).order_by(Blog.id_blog.desc())).all()


@app.get("/blog/{blog_id}", response_model=BlogRespuesta)
def obtener_blog(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
    _u: Usuario = Depends(usuario_actual),
):
    publicacion = db.get(Blog, blog_id)
    if publicacion is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
    return publicacion


@app.post("/blog", response_model=BlogRespuesta, status_code=201)
def crear_blog(
    datos: BlogCrear,
    db: Session = Depends(obtener_sesion),
    quien: Usuario = Depends(usuario_actual),
):
    nuevo = Blog(
        titulo=datos.titulo.strip(),
        descripcion=(datos.descripcion or "").strip(),
        img=datos.img.strip() if datos.img and datos.img.strip() else None,
        tags=datos.tags.strip() if datos.tags and datos.tags.strip() else None,
        usr_id=quien.id_usr,  # el autor sale del token, no del cliente
    )
    db.add(nuevo)
    try:
        db.commit()
        db.refresh(nuevo)
    except Exception:
        db.rollback()
        raise HTTPException(status_code=500, detail="No se pudo crear la publicación")
    return nuevo


# ----------------------------------------------------------- COMENTARIOS
@app.get("/comentarios", response_model=list[ComentarioRespuesta])
def listar_comentarios(
    blog_id: int | None = None,
    db: Session = Depends(obtener_sesion),
    _u: Usuario = Depends(usuario_actual),
):
    consulta = select(Comentario).where(Comentario.estatus == 1)
    if blog_id is not None:
        consulta = consulta.where(Comentario.blog_id == blog_id)
    return db.scalars(consulta.order_by(Comentario.id_com)).all()


@app.post("/comentarios", response_model=ComentarioRespuesta, status_code=201)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
    quien: Usuario = Depends(usuario_actual),
):
    texto = datos.comentario.strip()
    if not texto:
        raise HTTPException(status_code=422, detail="El comentario no puede estar vacío")
    if db.get(Blog, datos.blog_id) is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")

    nuevo = Comentario(
        comentario=texto,
        usr_id=quien.id_usr,  # autor tomado del token
        blog_id=datos.blog_id,
        estatus=1,
    )
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo
