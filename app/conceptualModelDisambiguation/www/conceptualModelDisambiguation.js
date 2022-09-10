// Read in data from "input.json" to populate variable list 

function display(input) {
    let o = "HELLO"; // output to add to the web page
  
    // Add generated content to the page
    const to = document.getElementById("info");
    to.innerHTML = o;
  
    // Update title
    window.onload = () => {
      // Make title more descriptive
      document.title = "rTisane: Conceptual Modeling"
  
    };  
  
}

function load(output) {
    (async () => {
      display(output);
    })(); 
}

function loadFetch() {
  console.log("here");
  fetch("input.json")
  .then(resp => {
    console.log("fetch json");
    console.log(resp)
    let output = resp.json();
    load(output);
  })
    // (async () => {
    //   let resp = await fetch("input.json");
    //   console.log(resp)
    //   let output = await resp.json();
    //   load(output);
    // })(); 
}

// loadFetch();