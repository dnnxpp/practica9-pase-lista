from datetime import datetime
from typing import List, Optional

import bcrypt
import uvicorn
from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, EmailStr
from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, func
from sqlalchemy.orm import Session, relationship

from database import Base, engine, get_db


TIPO_VISITANTE = 1  #tipo de usuario xddxd
TIPO_ADMIN = 2     #tipo de admin osea yo xdxdxdx


class Usuario(Base):
    __tablename__ = "usuario"

    id_usr = Column(Integer, primary_key=True, autoincrement=True)
    nom_usr = Column(String(100), nullable=False)
    mail = Column(String(150), nullable=False, unique=True)
    password = Column("pass", String(255), nullable=False)
    dir_usr = Column(String(255), nullable=True)
    tip_usu = Column(Integer, nullable=False, default=1)


class Blog(Base):
    __tablename__ = "blog"

    id_blog = Column(Integer, primary_key=True, autoincrement=True)
    titulo = Column(String(200), nullable=False)
    desc = Column(String(500), nullable=True)
    img = Column(String(255), nullable=True)
    tags = Column(String(255), nullable=True)


class Comentario(Base):
    __tablename__ = "comentarios"

    id_com = Column(Integer, primary_key=True, autoincrement=True)
    comentario = Column(String(500), nullable=False)
    fecha = Column(DateTime, nullable=False, server_default=func.now())
    estatus = Column(Integer, nullable=False, default=1)
    usr_id = Column(Integer, ForeignKey("usuario.id_usr", ondelete="CASCADE"), nullable=False)
    blog_id = Column(Integer, ForeignKey("blog.id_blog", ondelete="CASCADE"), nullable=False)

    usuario = relationship("Usuario")


class RegistroIn(BaseModel):
    nom_usr: str
    mail: EmailStr
    password: str
    dir_usr: Optional[str] = None


class LoginIn(BaseModel):
    mail: EmailStr
    password: str


class UsuarioUpdate(BaseModel):
    nom_usr: Optional[str] = None
    dir_usr: Optional[str] = None


class UsuarioOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: Optional[str] = None
    tip_usu: int


class BlogIn(BaseModel):
    titulo: str
    desc: Optional[str] = None
    img: Optional[str] = None
    tags: Optional[str] = None


class BlogOut(BlogIn):
    model_config = ConfigDict(from_attributes=True)
    id_blog: int


class ComentarioIn(BaseModel):
    comentario: str
    usr_id: int
    blog_id: int


class ComentarioUpdate(BaseModel):
    comentario: str


class ComentarioOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int
    blog_id: int
    nom_usr: Optional[str] = None

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API Who is Ale", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


def armar_comentario(c: Comentario) -> ComentarioOut:
    salida = ComentarioOut.model_validate(c)
    salida.nom_usr = c.usuario.nom_usr if c.usuario else None
    return salida

def verificar_admin(id_admin: int, db: Session):
    admin = db.query(Usuario).filter(Usuario.id_usr == id_admin).first()
    if admin is None or admin.tip_usu != TIPO_ADMIN:
        raise HTTPException(status_code=403, detail="Solo el administrador puede hacer esto")


@app.get("/")
def inicio():
    return {"mensaje": "API de Who is Ale funcionando"}


@app.post("/RegistroUsuario", response_model=UsuarioOut, status_code=201)
def registro_usuario(datos: RegistroIn, db: Session = Depends(get_db)):
    existe = db.query(Usuario).filter(Usuario.mail == datos.mail).first()
    if existe:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")

    hash_pass = bcrypt.hashpw(datos.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    nuevo = Usuario(
        nom_usr=datos.nom_usr,
        mail=datos.mail,
        password=hash_pass,
        dir_usr=datos.dir_usr,
        tip_usu=TIPO_VISITANTE,
    )
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo


@app.post("/Login", response_model=UsuarioOut)
def login(datos: LoginIn, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.mail == datos.mail).first()
    if usuario is None:
        raise HTTPException(status_code=401, detail="Correo o contraseña incorrectos")

    correcta = bcrypt.checkpw(datos.password.encode("utf-8"), usuario.password.encode("utf-8"))
    if not correcta:
        raise HTTPException(status_code=401, detail="Correo o contraseña incorrectos")

    return usuario


@app.get("/usuarios", response_model=List[UsuarioOut])
def listar_usuarios(id_admin: int, db: Session = Depends(get_db)):
    verificar_admin(id_admin, db)
    return db.query(Usuario).all()


@app.get("/usuarios/{id_usr}", response_model=UsuarioOut)
def obtener_usuario(id_usr: int, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id_usr == id_usr).first()
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario


@app.put("/usuarios/{id_usr}", response_model=UsuarioOut)
def actualizar_usuario(id_usr: int, datos: UsuarioUpdate, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.id_usr == id_usr).first()
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if datos.nom_usr is not None:
        usuario.nom_usr = datos.nom_usr
    if datos.dir_usr is not None:
        usuario.dir_usr = datos.dir_usr
    db.commit()
    db.refresh(usuario)
    return usuario


@app.delete("/usuarios/{id_usr}")
def eliminar_usuario(id_usr: int, id_admin: int, db: Session = Depends(get_db)):
    verificar_admin(id_admin, db)
    usuario = db.query(Usuario).filter(Usuario.id_usr == id_usr).first()
    if usuario is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    db.delete(usuario)
    db.commit()
    return {"mensaje": "Usuario eliminado"}


@app.get("/blogs", response_model=List[BlogOut])
def listar_blogs(tag: Optional[str] = None, db: Session = Depends(get_db)):
    consulta = db.query(Blog)
    if tag:
        consulta = consulta.filter(Blog.tags.like("%" + tag + "%"))
    return consulta.order_by(Blog.id_blog.desc()).all()


@app.get("/tags", response_model=List[str])
def listar_tags(db: Session = Depends(get_db)):
    categorias = []
    for blog in db.query(Blog).all():
        if blog.tags:
            for t in blog.tags.split(","):
                t = t.strip()
                if t != "" and t not in categorias:
                    categorias.append(t)
    categorias.sort()
    return categorias


@app.get("/blogs/{id_blog}", response_model=BlogOut)
def obtener_blog(id_blog: int, db: Session = Depends(get_db)):
    blog = db.query(Blog).filter(Blog.id_blog == id_blog).first()
    if blog is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
    return blog


@app.post("/blogs", response_model=BlogOut, status_code=201)
def crear_blog(datos: BlogIn, id_admin: int, db: Session = Depends(get_db)):
    verificar_admin(id_admin, db)
    nuevo = Blog(titulo=datos.titulo, desc=datos.desc, img=datos.img, tags=datos.tags)
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo


@app.put("/blogs/{id_blog}", response_model=BlogOut)
def actualizar_blog(id_blog: int, datos: BlogIn, id_admin: int, db: Session = Depends(get_db)):
    verificar_admin(id_admin, db)
    blog = db.query(Blog).filter(Blog.id_blog == id_blog).first()
    if blog is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
    blog.titulo = datos.titulo
    blog.desc = datos.desc
    blog.img = datos.img
    blog.tags = datos.tags
    db.commit()
    db.refresh(blog)
    return blog


@app.delete("/blogs/{id_blog}")
def eliminar_blog(id_blog: int, id_admin: int, db: Session = Depends(get_db)):
    verificar_admin(id_admin, db)
    blog = db.query(Blog).filter(Blog.id_blog == id_blog).first()
    if blog is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")
    db.delete(blog)
    db.commit()
    return {"mensaje": "Publicación eliminada"}

@app.get("/blogs/{id_blog}/comentarios", response_model=List[ComentarioOut])
def listar_comentarios(id_blog: int, db: Session = Depends(get_db)):
    blog = db.query(Blog).filter(Blog.id_blog == id_blog).first()
    if blog is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")

    comentarios = (
        db.query(Comentario)
        .filter(Comentario.blog_id == id_blog, Comentario.estatus == 1)
        .order_by(Comentario.fecha.desc())
        .all()
    )
    return [armar_comentario(c) for c in comentarios]


@app.post("/comentarios", response_model=ComentarioOut, status_code=201)
def crear_comentario(datos: ComentarioIn, db: Session = Depends(get_db)):
    if db.query(Usuario).filter(Usuario.id_usr == datos.usr_id).first() is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if db.query(Blog).filter(Blog.id_blog == datos.blog_id).first() is None:
        raise HTTPException(status_code=404, detail="Publicación no encontrada")

    nuevo = Comentario(comentario=datos.comentario, usr_id=datos.usr_id, blog_id=datos.blog_id)
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return armar_comentario(nuevo)


@app.put("/comentarios/{id_com}", response_model=ComentarioOut)
def actualizar_comentario(id_com: int, id_usr: int, datos: ComentarioUpdate, db: Session = Depends(get_db)):
    comentario = db.query(Comentario).filter(Comentario.id_com == id_com).first()
    if comentario is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")
    if comentario.usr_id != id_usr:
        raise HTTPException(status_code=403, detail="Solo puedes editar tus propios comentarios")
    comentario.comentario = datos.comentario
    db.commit()
    db.refresh(comentario)
    return armar_comentario(comentario)


@app.delete("/comentarios/{id_com}")
def eliminar_comentario(id_com: int, id_usr: int, db: Session = Depends(get_db)):
    comentario = db.query(Comentario).filter(Comentario.id_com == id_com).first()
    if comentario is None:
        raise HTTPException(status_code=404, detail="Comentario no encontrado")

    quien = db.query(Usuario).filter(Usuario.id_usr == id_usr).first()
    es_admin = quien is not None and quien.tip_usu == TIPO_ADMIN
    if comentario.usr_id != id_usr and not es_admin:
        raise HTTPException(status_code=403, detail="No tienes permiso para borrar este comentario")

    comentario.estatus = 0
    db.commit()
    return {"mensaje": "Comentario eliminado"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)