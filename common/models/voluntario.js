'use strict';

var assert = require('assert');

module.exports = function (Voluntario) {
  Voluntario.remoteMethod('promover', {
    description: 'Promueve un voluntario al rol de coordinador.',
    accepts: [{arg: 'voluntarioId', type: 'string', required: true, description: 'id del voluntario'}],
    returns: {arg: 'resultado', type: 'string'}
  });

  Voluntario.remoteMethod('degradar', {
    description: 'Quita el rol de coordinador a un voluntario.',
    accepts: [{arg: 'voluntarioId', type: 'string', required: true, description: 'id del voluntario'}],
    returns: {arg: 'resultado', type: 'string'}
  });

  Voluntario.promover = function (id, cb) {
    var app = Voluntario.app;
    var Role = app.models.Role;
    var RoleMapping = app.models.RoleMapping;

    var findVoluntario = Voluntario.findById(id);
    var findCoordinadorRole = Role.find({where: {name: 'coordinador'}});

    Promise.all([findVoluntario, findCoordinadorRole])
      .then(function (results) {
        var voluntario = results[0];
        var coordinadorRole = results[1][0];
        assert(voluntario, "No existe un voluntario con ese id");
        assert(coordinadorRole, "No se encontró el rol coordinador, reportelo este error con el administrador.");

        return coordinadorRole.principals.create(
          {
            principalType: RoleMapping.USER,
            principalId: voluntario.id
          });
      }).then(function () {
      cb(null, "El voluntario " + id + " fue promovido a Coordinador.");
    }).catch(function (err) {
      cb(err)
    });
  };

  Voluntario.degradar = function (id, cb) {
    var Role = Voluntario.app.models.Role;
    var RoleMapping = Voluntario.app.models.RoleMapping;

    var findVoluntario = Voluntario.findById(id);
    var findCoordinadorRole = Role.find({where: {name: 'coordinador'}});

    Promise.all([findVoluntario, findCoordinadorRole])
      .then(function (results) {
        var voluntario = results[0];
        var coordinadorRole = results[1][0];
        assert(voluntario, "No existe un voluntario con ese id");
        assert(coordinadorRole, "No se encontró el rol coordinador, reportelo este error con el administrador.");

        return coordinadorRole.principals.destroyAll({
            principalType: RoleMapping.USER,
            principalId: voluntario.id
        });

      }).then(function (result) {
      cb(null, "El voluntario " + id + " ya NO es Coordinador.");
    }).catch(function (err) {
      cb(err)
    });
  };
};
