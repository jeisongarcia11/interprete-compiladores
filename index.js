// Import stylesheets
import './style.css';
import $ from 'jquery';

var parser = require('./grammar');
var funciones = require('./data.js').funciones;
const Swal = require('sweetalert2');

$(function() {
  $('#editor').on('keydown', function(e) {
    if (e.key == 'Tab') {
      e.preventDefault();
      var start = this.selectionStart;
      var end = this.selectionEnd;

      // set textarea value to: text before caret + tab + text after caret
      this.value =
        this.value.substring(0, start) + '\t' + this.value.substring(end);

      // put caret at right position again
      this.selectionStart = this.selectionEnd = start + 1;
    }
  });

  $('#compilar').click(() => {
    var salida = $('#out');
    salida.text('>>');
    var texto, res;

    texto = $('#editor').val();

    var resultado = '';
    try {
      funciones.clear();
      parser.parse(texto);
      resultado = 'Compilado correctamente';
    } catch (error) {
      resultado = 'Error: ' + error;
    }

    salida.text('>> ' + resultado);
  });

  $('#limpiar').click(() => {
    var salida = $('#out');
    salida.text('>>');
    $('#editor').text('');
  });
});
