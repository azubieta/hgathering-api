'use strict';

module.exports = function (Acopio) {

  Acopio.remoteMethod('centrosDeAcopioCercanos', {
    description: 'Lista centros de acopio cercanos al posición en un radio especificado.',
    accepts: [
      {arg: 'loc', type: 'GeoPoint', required: true, description: 'ubicación de referencia'},
      {arg: 'radio', type: 'number', required: true, description : 'distancia en kilometros'}],
    returns: {arg: 'centros de acopio', type: 'array'}
  });

  Acopio.centrosDeAcopioCercanos = function (loc, radio, cb) {
    var list = [];
    Acopio.find({})
      .then(function (result) {
          for (var i = 0; i < result.length; i++) {
            var centro = result[i];
            if (centro.geopos) {
              var distance = loc.distanceTo(centro.geopos, {type: 'kilometers'});
              if (distance <= radio)
                list.push(centro);
            }
          }

          cb(null, list);
        }
      ).catch(function (error) {
      cb(error)
    });
  }
}
;
