document.addEventListener("DOMContentLoaded", function () {
    const logoutButton = document.getElementById('logout-button');

    logoutButton.addEventListener('click', function (event) {
        event.preventDefault();

        fetch('http://127.0.0.1:8000/logout/', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Token ${localStorage.getItem('token')}`
            }
        })
        .then(response => {
            if (response.ok) {
                localStorage.removeItem('token');
                window.location.href = 'login.html';  // Redirect to login page after logout
            } else {
                console.error('Logout failed');
            }
        })
        .catch(error => console.error('Error during logout:', error));
    });
});
