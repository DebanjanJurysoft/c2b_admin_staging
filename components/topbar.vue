<template>
    <div class="topbar-container">
        <div class="search-container" :style="selectedMenu.name == 'home' ? 'visibility: hidden' : ''">
            <i class="fa fa-search"></i>
            <input type="text" @input.prevent="changeSearchData" v-model="selectedMenu.searchText" :placeholder="`Search ${selectedMenu.name}`">
        </div>
        <div class="faq-container">
            <div class="faq-button"></div>
        </div>
        <div class="notification-container">
            <div class="notification-button">
                <img v-if="notification.length == 0" src="~/static/icons/no-notification.svg" alt="no-notification">
                <img v-else src="~/static/icons/notification.svg" alt="notification">
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() { 
        return {
            notification: [],
            timer: null,
        }
    },
    methods: {
        emitSearchText() { 
            this.$emit('updateNewActive', this.selectedMenu)
        },
        changeSearchData() {
            clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                this.emitSearchText()
            }, 300);
        }
    },
    props: ['selectedMenu']
}
</script>