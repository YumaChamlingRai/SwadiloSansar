// Get the current URL
var currentPage = window.location.href;

// Get all navigation links
var navLinks = document.querySelectorAll('.nav-link');

// Loop through each navigation link
navLinks.forEach(function(link) {
  // Check if the link's href matches the current URL
  if (link.href === currentPage) {
    // Add 'active' class to the matching link
    link.classList.add('active');
  }
});





