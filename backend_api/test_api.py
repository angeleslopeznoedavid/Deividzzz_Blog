import sys; sys.path.insert(0, '.')
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient
import database, main
eng = create_engine("sqlite://", connect_args={"check_same_thread":False}, poolclass=StaticPool)
database.Base.metadata.create_all(eng)
S = sessionmaker(bind=eng)
def ses():
    d=S()
    try: yield d
    finally: d.close()
main.app.dependency_overrides[database.obtener_sesion]=ses
c = TestClient(main.app, raise_server_exceptions=False)
res=[]
def chk(nombre, obtenido, esperado):
    ok = obtenido==esperado; res.append(ok)
    print(("OK  " if ok else "FALLA"), nombre, "->", obtenido, "(esperado", esperado, ")")

chk("crear admin", c.post("/usuarios",json={"nom_usr":"Admin","mail":"a@a.com","password":"12345678","tip_usu":1}).status_code, 201)
chk("crear usuario normal", c.post("/usuarios",json={"nom_usr":"Otro","mail":"o@o.com","password":"12345678","tip_usu":2}).status_code, 201)
r=c.post("/login",json={"mail":"A@a.com","password":"12345678"})
chk("login (mail en mayúsculas)", r.status_code, 200)
chk("login devuelve id_usr", "id_usr" in r.json(), True)
chk("login clave mala", c.post("/login",json={"mail":"a@a.com","password":"mala"}).status_code, 401)

r=c.put("/usuarios/1",json={"nom_usr":"Admin Nuevo","mail":"A@A.com","dir_usr":"Calle 1","tip_usu":1})
chk("PUT usuario válido", r.status_code, 200)
chk("PUT normaliza correo y guarda dirección", (r.json()["mail"], r.json()["dir_usr"]), ("a@a.com","Calle 1"))
chk("PUT inexistente", c.put("/usuarios/99",json={"nom_usr":"Xx","mail":"x@x.com"}).status_code, 404)
chk("PUT nombre 1 carácter", c.put("/usuarios/1",json={"nom_usr":"X","mail":"x@x.com"}).status_code, 422)
chk("PUT tip_usu=9", c.put("/usuarios/2",json={"nom_usr":"Otro","mail":"o@o.com","tip_usu":9}).status_code, 422)
chk("PUT sin tip_usu conserva rol", c.put("/usuarios/2",json={"nom_usr":"Otro","mail":"o@o.com"}).json()["tip_usu"], 2)

chk("POST blog válido", c.post("/blog",json={"titulo":"Mi post","descripcion":"texto"}).status_code, 201)
r=c.post("/blog",json={"titulo":"  Mi post  ","descripcion":"  texto  ","img":"   ","tags":"flutter, IA"})
chk("POST blog limpia espacios / img vacía→null", (r.json()["titulo"], r.json()["img"]), ("Mi post", None))
chk("POST blog sin descripción", c.post("/blog",json={"titulo":"Hola"}).status_code, 422)
chk("POST blog título 1 carácter", c.post("/blog",json={"titulo":"H","descripcion":"x"}).status_code, 422)
chk("POST blog descripción solo espacios", c.post("/blog",json={"titulo":"Hola","descripcion":"   "}).status_code, 422)
chk("GET /blog lista", len(c.get("/blog").json()), 2)

# comentario para probar FK al borrar
c.post("/comentarios",json={"comentario":"hola","usr_id":2,"blog_id":1})
chk("DELETE usuario con comentarios (FK)", c.delete("/usuarios/2").status_code, 204 if True else 409)
chk("DELETE inexistente", c.delete("/usuarios/99").status_code, 404)
print("\nRESULTADO:", sum(res), "de", len(res), "pruebas OK")
