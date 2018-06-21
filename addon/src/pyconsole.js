"use strict";

let scrollCount = 0;
let pyinput = document.getElementById('pyinput');

function submit() {
    let output = document.getElementById("output");
    let input = pyinput.value;

    // Setup output display
    let result = document.createElement('div');
    result.className = 'result';

    let displayInput = document.createElement('div');
    displayInput.className = 'display-input';
    displayInput.appendChild(document.createTextNode(input));

    result.appendChild(displayInput);

    // Run python
    try {
        let response = pyodide.runPython(input);
        if (response !== undefined) {
            let displayOutput = document.createElement('pre');
            displayOutput.className = 'display-output';
            displayOutput.appendChild(document.createTextNode(response));
            result.appendChild(displayOutput);
        }
    }
    catch(error) {
        let displayError = document.createElement('pre');
        displayError.className = 'display-error';
        displayError.appendChild(document.createTextNode(error.message));
        result.appendChild(displayError);
    }

    // Display it
    output.appendChild(result);
    scrollCount = scrollCount + result.getBoundingClientRect().height;
    output.scrollTop = scrollCount;

    // Finally clear input so we can go again
    pyinput.value = '';
};

pyinput.addEventListener('keyup', (event) => {
    if (event.which == 13) {
        submit();
    }
});
