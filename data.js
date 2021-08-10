const funciones = {
  function: [],
  vars: [],

  insertarFuncion: function(tipo, id, param, body) {
    if (this.validarFuncion(id)) {
      var fun = { tipo: tipo, id: id, param: [param], body: body };
      this.function.push(fun);
      return fun;
    } else {
      throw 'No puedes declarar dos funciones con el mismo nombre <<' +
        id +
        '>>'; 
    }
  },
  validarFuncion: function(id) {
    for (let index = 0; index < this.function.length; index++)
      if (this.function[index].id === id) return false;

    return true;
  },
  declararVariable: function(id) {
    if (this.validarVariable(id)) {
      var v = { id: id, value: undefined };
      this.vars.push(v);
      return v;
    }
    throw 'No puedes declarar dos variables con el mismo nombre <<' + id + '>>';
  },

  actualizarVariable: function(id, value) {
    var index = this.validarVariable2(id);
    var v;
    if (index !== -1) {
      if (value === 'true' || value === 'false') v = value === true;
      else {
        if (isNaN(parseFloat(value))) {
          v = value;
        } else {
          v = Number(value);
        }

        var elem = { id: id, value: v };
        this.vars.splice(index, 1);
        this.vars.push(elem);
        return elem;
      }
    } else {
      throw 'la variable <<' + id + '>> no existe';
    }
  },
  extraerVariable: function(id) {
    for (let index = 0; index < this.vars.length; index++)
      if (this.vars[index].id === id) return this.vars[index].value;

    throw 'Error - la variable no existe';
  },

  validarVariable: function(id) {
    for (let index = 0; index < this.vars.length; index++)
      if (this.vars[index].id === id) return false;

    return true;
  },

  validarVariable2: function(id) {
    for (let index = 0; index < this.vars.length; index++)
      if (this.vars[index].id === id) return index;

    return -1;
  },

  operar_OFuncion: function() {},

  OperacionesNumericas: function(eIzq, eDer, Op) {
    if (Op === '+') return eIzq + eDer;
    else if (Op === '-') return eIzq - eDer;
    else if (Op === '*') return eIzq * eDer;
    else if (Op === '/') return eIzq / eDer;
  },

  clear: function() {
    this.vars = [];
    this.function = [];
  }
};

module.exports.funciones = funciones;
