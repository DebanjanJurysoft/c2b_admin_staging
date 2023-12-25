<template>
    <b-pagination 
        align="right" 
        v-if="data_list.length != 0 && total_rows > per_page" 
        v-model="page" 
        first-number
        last-number
        variant="primary"
        :per-page="per_page" 
        :total-rows="total_rows"
    ></b-pagination>
</template>

<script>
export default {
    props: ['selected_tab', 'per_page', 'total_rows', 'data_list', 'page'],
    data() {
        return {
            timer: null
        }
    },
    mounted() {
        console.log(this.page);
    },
    watch: {
        page(val) {
            clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                this.$emit('changePage', val)
            }, 300);
        }
    }
}
</script>

<style>
.page-item.active .page-link {
    z-index: 3;
    color: #fff;
    background-color: #e74c3c;
    border-color: #e74c3c;
}
.page-link {
    position: relative;
    display: block;
    padding: 0.5rem 0.75rem;
    margin-left: -1px;
    line-height: 1.25;
    color: #e74c3c;
    background-color: #fff;
    border: 1px solid #dee2e6;
}
</style>