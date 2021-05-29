
function copyToClipboard(str){
	var el = document.createElement('textarea');
	el.value = str;
	document.body.appendChild(el);
	el.select();
	document.execCommand('copy');
	document.body.removeChild(el);
};

$('table').mousedown(function (e) {
    var cell = $(e.target).closest("td");
	if (typeof(cell.parent()[0]) !== 'undefined') {
		cell.css("background-color", "#1c8613");
	}
});

$('table').mouseup(function (e) {
    var cell = $(e.target).closest("td");
	if (typeof(cell.parent()[0]) !== 'undefined') {
		copyToClipboard(cell.text());
		cell.css("background-color", "");
	}
});