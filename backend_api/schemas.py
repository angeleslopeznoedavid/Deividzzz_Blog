from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class UsuarioCrear(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=128)
    dir_usr: str | None = None
    tip_usu: int = 2


class UsuarioActualizar(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    dir_usr: str | None = None
    tip_usu: int | None = None


class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None
    tip_usu: int

    model_config = ConfigDict(from_attributes=True)


class LoginRequest(BaseModel):
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)


class LoginRespuesta(UsuarioRespuesta):
    access_token: str
    token_type: str = "bearer"


class BlogCrear(BaseModel):
    titulo: str = Field(min_length=1, max_length=150)
    descripcion: str | None = None
    img: str | None = Field(default=None, max_length=500)
    tags: str | None = Field(default=None, max_length=255)


class BlogRespuesta(BaseModel):
    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None
    fecha: datetime
    usr_id: int | None = None
    autor: str

    model_config = ConfigDict(from_attributes=True)


class ComentarioCrear(BaseModel):
    comentario: str = Field(min_length=1, max_length=2000)
    blog_id: int
    # Se ignora: el autor siempre es el usuario del token.
    usr_id: int | None = None


class ComentarioRespuesta(BaseModel):
    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int
    blog_id: int
    autor: str

    model_config = ConfigDict(from_attributes=True)
