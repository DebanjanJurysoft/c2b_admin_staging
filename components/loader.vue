<template>
    <div class="loader-container">
        <b-spinner class="loader" variant="primary" label="Spinning"></b-spinner>
        <h3 class="text-primary text-center">{{ text ? text : 'Loading...' }}</h3>
    </div>
</template>
<script>
export default {
    props: ['text'],
}
</script>
<style>
.loader-container {
    width: 100%;
    height: 75vh;
    display: flex;
    gap: 20px;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}
.loader {
    scale: 1.2;
}

</style>