# Help Gathering Api

Api para reunir información de los centros de acopio habilitados para apoyar a los damnificados por los sismos en
México 2017.

Desplegada en:
http://ec2-54-242-119-209.compute-1.amazonaws.com

Documentación:
 - http://ec2-54-242-119-209.compute-1.amazonaws.com/explorer/
 - https://loopback.io/doc/en/lb3/index.html

## Instalación

Primero clona este repositorio como sigue:

```
git clone https://github.com/azubieta/hgathering-api.git
```

Adentro del directorio del repositorio, puedes instalar las dependencias con `npm install`. Es importante contar con la versión 5 o mayor de NPM para utilizar el archivo lock de versiones de dependencias `package-lock.json`.

Para habilitar un ambiente de desarrollo, puedes utilizar el script del proyecto como sigue:

```
./hgathering.sh <comando> [<arg1>]
```

Donde `<comando>` es una de las siguientes opciones:

- `start`: Inicia el servicio con npm start
- `mongo-fresh`: Crea un nuevo contenedor basado en la imagen de `mongo:3.4`.
- `mongo-start`: Inicia el contenedor de mongo ya existente.
- `mongo-rmf`: Elimina el contenedor de mongo existente.
- `mongo-restore`: Restaura el dump de una bd en la instancia local de mongo. Aquí se utiliza `<arg1>` como el directorio en donde se encuentran los archivos del dump.
- `redis-fresh`: Crea un nuevo contenedor basado en la imagen de `redis:3.4-alpine`.
- `redis-start`: Inicia el contenedor de redis ya existente.
- `redis-rmf`: Elimina el contenedor de redis existente.

Si deseas consultar y probar la especificación de la API, puedes acceder a `http://localhost:3000/explorer` una vez que el servicio este corriendo.
