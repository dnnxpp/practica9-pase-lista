import bcrypt

from database import SessionLocal
from main import Blog, Usuario, TIPO_ADMIN

ADMIN_NOMBRE = "admin"
ADMIN_MAIL = "admin@gmail.com"
ADMIN_PASSWORD = "huevos123"

if __name__ == "__main__":
    db = SessionLocal()

    admin = db.query(Usuario).filter(Usuario.mail == ADMIN_MAIL).first()
    if admin is None:
        hash_pass = bcrypt.hashpw(ADMIN_PASSWORD.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        admin = Usuario(nom_usr=ADMIN_NOMBRE, mail=ADMIN_MAIL, password=hash_pass, tip_usu=TIPO_ADMIN)
        db.add(admin)
        db.commit()
        print("Administrador creado:", ADMIN_MAIL)
    else:
        print("El administrador ya existía:", ADMIN_MAIL)

    if db.query(Blog).count() == 0:
        publicaciones = [
            Blog(titulo="Mis videojuegos favoritos",
                 desc="Los juegos que más disfruto y por qué me gustan tanto.",
                 img="videojuegos.jpg", tags="videojuegos"),
            Blog(titulo="La música que me acompaña",
                 desc="Los artistas y canciones que escucho todos los días.",
                 img="musica.jpg", tags="musica"),
            Blog(titulo="Quiero aprender a tocar el piano",
                 desc="Por qué quiero aprender piano y cómo voy a empezar.",
                 img="piano.jpg", tags="piano,musica"),
            Blog(titulo="Un poco sobre mí",
                 desc="Cosas que me gustan y que no caben en otra categoría.",
                 img="sobre-mi.jpg", tags="sobre-mi"),
        ]
        db.add_all(publicaciones)
        db.commit()
        print("Publicaciones de ejemplo creadas:", len(publicaciones))
    else:
        print("Ya hay publicaciones, no se agregaron las de ejemplo")

    db.close()