let edit = false;
let pendingNote = null;

let disabledInputs = (bool) => {
	$("#textarea").prop("disabled", bool);
};

let hidePrintDialog = () => {
	$("#print-dialog").fadeOut(200);
};

let clearInputs = () => {
	$("#page-title").text("Notepad");
	$("#textarea").val("");
	$("#button").text("Salva");
	pendingNote = null;
	hidePrintDialog();
};

let sendNote = (anonymous) => {
	if (!pendingNote) return;

	$.post(
		`https://${GetParentResourceName()}/giveItemNote`,
		JSON.stringify({
			title: pendingNote.title,
			object: pendingNote.object,
			anonymous: anonymous,
		})
	);

	$("#container").fadeOut(500);
	clearInputs();
};

window.addEventListener("message", (event) => {
	let action = event.data;

	if (action.action === "view") {
		$("#container").fadeIn(500);
		$("#container").css("display", "flex");
	
		$("#page-title").text(action.metadata.title);
		$("#textarea").val(action.metadata.object);
		$("#button").text(action.metadata.save);

		disabledInputs(true);
		edit = false;
	} else if (action.action === "create") {
		$("#container").fadeIn(500);
		$("#container").css("display", "flex");
		$("#page-title").text(action.metadata.title);
		$("#button").text("Salva");

		disabledInputs(false);
		edit = true;
	}
});

$(document).on("click", "#button", function () {
	if (edit) {
		pendingNote = {
			title: $("#page-title").text(),
			object: $("#textarea").val(),
		};

		$("#print-dialog").fadeIn(200).css("display", "flex");
	}
});

$(document).on("click", "#print-anonymous", function () {
	sendNote(true);
});

$(document).on("click", "#print-name", function () {
	sendNote(false);
});

$(document).on("click", "#print-cancel", function () {
	pendingNote = null;
	hidePrintDialog();
});

document.onkeyup = function (data) {
	if (data.which == 27) {
		$.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));

		$("#container").fadeOut(500);
		clearInputs();
	}
};
