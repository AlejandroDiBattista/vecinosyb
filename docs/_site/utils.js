function tag(name) {
    return document.getElementsByTagName(name)[0];
}

function set(e, propiedad, valor) {
    e.style.setProperty(propiedad, valor + "px");
}

function ir(name) {
    var e = document.getElementById(name);
    var h = tag('header').offsetHeight;

    window.scroll({ top: e.offsetTop - h - 8 });
}

function acomodar() {
    var s = document.getElementById('regreso');
    var h = tag('header').offsetHeight;
    var w = tag('header').offsetWidth;

    set(s, 'top', h - 40 - 10);
    set(s, 'left', w - 150 - 10);
    set(s, 'width', 150);
    set(s, 'height', 40);

    set(tag('body'), 'margin-top', h);
}

function iniciar() {
    acomodar();
    ir("farmacias");
}