<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row">
                <div class="w-75">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="customers" :per_page="per_page" :total_rows="total" :page="page"/>
                </div>
            </div>
            <Table :headings="heading" :data_rows="customers" />
            <Pagination @changePage="changePage" :data_list="customers" :per_page="per_page" :total_rows="total" :page="page"/>
            <!-- <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="'Product Details'" :product_details="product_details"/> -->
        </div>
    </div>
</template>

<script>
import Loader from './loader.vue';

export default {
    props: ['searchText'],
    data() {
        return {
            loader: false,
            page: 1,
            per_page: 7,
            heading: [
                {
                    name: 'customer name',
                    icon: 'fa fa-user-o'
                },
                {
                    name: 'address',
                    icon: 'fa fa-home',
                },
                {
                    name: 'cart items',
                    icon: 'fa fa-shopping-cart',
                    onclick: true
                },
            ],
            total: 99,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            customers: []
        };
    },
    components: { Loader },
    watch: {
        searchText(val) {
            clearTimeout(this.timer)
            this.timer = setTimeout(async () => {
                this.loader = true
                await this.fetchCustomers()
                this.loader = false
            }, 300);
        },
        per_page() {
            this.changePage(this.page)
        },
    },
    async mounted() { 
        this.loader = true
        await this.fetchCustomers()
        this.loader = false
    },
    methods: {
        async changePage(page_no) {
            this.page = page_no
            this.fetchCustomers()
            window.scrollTo(0,0);
        },
        async fetchCustomers() {
            let query = `/fetch-customers?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
            if (this.searchText && this.searchText != '') {
                query = query + `&q=${this.searchText}`
            }
            const response = await this.$axios.get(query)
            this.total = response.data.total
            this.customers = response.data.customers.map(cust => {
                return {
                    'customer name': cust.fullname,
                    'address': 'Address',
                    'cart items': 10,
                    full_data: cust
                }
            })
        }
    }
}
</script>