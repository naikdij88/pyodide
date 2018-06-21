function submit() {
    let text = document.getElementById("pyinput").value;
    let response = pyodide.runPython(text);
    console.log(response);
};

function enterPressed() {
    let input = document.getElementById('pyinput');
    input.addEventListener('keyup', (event) => {
        if (event.which == 13) {
            submit();
        }
    });
};

enterPressed();
