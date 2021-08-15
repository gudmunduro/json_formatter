
const onFormatClick = async event => {
    try {
        const jsonTextEl = document.getElementById('json-text');

        const jsonContent = jsonTextEl.value;
        const res = await axios.post('/api/json/formatted', jsonContent, {
            headers: { 'Content-Type': 'text/plain' },
            responseType: 'text',
            transformResponse: res => res
        });
        jsonTextEl.value = res.data;
    }
    catch (e) {
        alert("Failed to format json");
        console.log(e);
    }
};

document.getElementById('format-button').addEventListener('click', onFormatClick);