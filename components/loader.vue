<template>
    <div class="loader-container">
        <b-spinner class="loader" label="Spinning"></b-spinner>
        <!-- <h3 class="text-center">{{ text ? text : 'Loading...' }}</h3> -->
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
    color: #e74c3c !important;
}
.loader {
    color: #e74c3c !important;
}
</style>