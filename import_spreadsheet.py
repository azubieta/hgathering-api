#!/usr/bin/env python3

import requests
import csv
import json
import logging
from io import StringIO

source_data = ''
try:
    source = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vQ6CChYk0cXlp_R_L2r9Enkar8qmDdGtu2CCE6dYYdU391PBt6zzePYQAkTJ5zJ6DHvkPsWu3Oty206/pub?gid=447869804&single=true&output=csv'
    data_request = requests.get(source)
    source_data = data_request.content.decode()
    if 'Inténtalo de nuevo' in source_data:
        raise Exception('Demasiadas solicitudes')
except Exception as e:
    logging.exception('No se pudieron obtener los datos de google')
    exit(1)

api_url = 'https://hapi.balterbyte.com/api'
headers = {'Content-type': 'application/json', 'Accept': 'application/json', 'Cache-Control': 'no-cache'}

def upsert_acopio(data):
    url = api_url + '/acopios'
    verify_url = api_url + '/acopios?filter={"where":{"legacy_id":"' + data['legacy_id'] + '"}}'

    r = requests.get(verify_url, data=json.dumps(data), headers=headers)
    response = r.json()
    if len(response) > 0:
        idAcopio = response[0]['id']
        update_url = api_url + '/acopios/{}'.format(idAcopio)
        r = requests.put(update_url, data=json.dumps(data), headers=headers)
        logging.debug(r.json())
        if r.status_code != 200:
            return

        return r.json()
    else:
        r = requests.post(url, data=json.dumps(data), headers=headers)
        if r.status_code != 200:
            return

        return r.json()

def upsert_contacto(data):
    url = api_url + '/contactos'
    verify_url = api_url + '/contactos?filter={"where":{"legacy_id":"' + data['legacy_id'] + '"}}'

    r = requests.get(verify_url, data=json.dumps(data), headers=headers)
    response = r.json()
    if len(response) > 0:
        idContacto = response[0]['id']
        update_url = api_url + '/contactos/{}'.format(idContacto)
        r = requests.put(update_url, data=json.dumps(data), headers=headers)
        if r.status_code != 200:
            return

        return r.json()
    else:
        r = requests.post(url, data=json.dumps(data), headers=headers)
        if r.status_code != 200:
            return

        return r.json()


def upsert_productos(idAcopio, productos):
    url = api_url + '/acopios/{}/productos'.format(idAcopio)
    requests.delete(url, headers=headers)

    for producto in productos:
        data = {"nombre": producto.strip()}
        r = requests.post(url, data=json.dumps(data), headers=headers)
        if r.status_code != 200:
            logging.warning("Unable to register product {} in {}".format(producto, idAcopio))

f = StringIO(source_data)
reader = csv.DictReader(f)
i = 0
for row in reader:
    i += 1
    logging.info("Processing row {}".format(i))
    try:
        data = {
            'legacy_id': row['id'],
            'nombre': row['Nombre del centro de acopio'],
            'direccion': row['Dirección (agregada)'],
        }

        try:
            data['geopos'] = {'lat': float(row['lat']), 'lng': float(row['lon'])}
        except Exception as e:
            logging.warning("posición geografica ignorada lat:{} long:{}".format(row['lat'], row['lon']))


        acopio = upsert_acopio(data)
        if not acopio:
            logging.info('retry lat and long switched')
            try:
                data['geopos'] = {'lat': float(row['lon']), 'lng': float(row['lat'])}
            except Exception as e:
                logging.warning("posición geografica ignorada row: {} lat:{} long:{}".format(row['ID'], row['lon'], row['lat']))

            acopio = upsert_acopio(data)

        if not acopio:
            logging.error('fila ignorada ID: {}'.format(json.dumps(data)))
            continue

        # POST CONTACT
        contact_data = {
            "legacy_id": "{}-{}".format(data['legacy_id'], 1),
            "acopioId": acopio['id'],
            "nombre": row['Nombre Contacto'],
            "email": row['Correo'],
            "twitter": row['Twitter'],
            "facebook": row['Facebook'],
            "telefono": row['Teléfono']
        }

        contacto = upsert_contacto(contact_data)
        if not contacto:
            logging.error("no se pudo agregar el contacto {}".format(json.dumps(contact_data)))


        # POST PRODUCTS
        productos_raw = row['Necesidades']
        productos_raw = productos_raw.replace('y', ',')
        productos_raw = productos_raw.replace('.', ',')
        productos = productos_raw.split(",")

        upsert_productos(acopio['id'], productos)

        logging.info("OK")

    except Exception as e:
        logging.exception("fila ignorada {}".format(row))
