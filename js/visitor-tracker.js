const VISITOR_KEY = "coffee-rise-last-visited";
const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

function shouldCountVisit() {
    const lastVisit = localStorage.getItem(VISITOR_KEY);

    // First time visitor
    if (!lastVisit) {
        return true;
    }

    const lastVisitTime = parseInt(lastVisit, 10);
    const now = Date.now();

    // More than 30 days passed → count as new visit
    return (now - lastVisitTime > THIRTY_DAYS_MS);
}

// Only track if conditions are met
if (shouldCountVisit()) {
    fetch("https://ik4gol29ge.execute-api.ap-south-1.amazonaws.com/track", {
        method: "GET",
        mode: "no-cors",
        cache: "no-store"
    }).catch(() => {}); // silent fail

    // Update last visit time
    localStorage.setItem(VISITOR_KEY, Date.now().toString());
}

/*<script>
    fetch('https://5ek3s8ys79.execute-api.ap-south-1.amazonaws.com/track')
        .then(response => response.json())
        .then(data => console.log('Total visits:', data.total_visits))
        .catch(error => console.error('Tracking error:', error));
</script>*/