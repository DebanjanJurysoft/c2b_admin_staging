<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row">
                <div class="w-75 d-flex flex-row align-items-center" style="gap: 10px;">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                    <button class="button" @click.prevent="reload"><i class="fa fa-refresh"></i></button>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="customers" :per_page="per_page" :total_rows="total" :page="page"/>
                </div>
            </div>
            <Table :note="{ text: 'Click On The Name / Address / Cart Items To See Details.', class: 'text-danger' }" @openSpecific="openSpecific" :headings="heading" :data_rows="customers"  :file_name="'user_list.csv'" :page="page" :rows="per_page"/>
            <Pagination @changePage="changePage" :data_list="customers" :per_page="per_page" :total_rows="total" :page="page"/>
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="sidebar_title" v-if="customer_cart_details" :cart_details="customer_cart_details"/>
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="sidebar_title" v-if="customer_addresses" :address_details="customer_addresses"/>
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="sidebar_title" v-if="customer" :customer="customer" />
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
                    icon: 'fa fa-user-o',
                    onclick: true,
                    onclick_emit: 'profile'
                },
                {
                    name: 'address',
                    icon: 'fa fa-home',
                    onclick: true,
                    onclick_emit: 'address'
                },
                {
                    name: 'cart items',
                    icon: 'fa fa-shopping-cart',
                    onclick: true,
                    onclick_emit: 'cart'
                },
            ],
            total: 0,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            customers: [],
            customer_cart_details: null,
            customer_addresses: null,
            show_details: false,
            sidebar_title: '',
            customer: null
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
        async reload() {
            this.loader = true
            this.page = 1
            await this.fetchCustomers()
            this.$emit('reloadDashboard')
            this.loader = false
        },
        async openSpecific(data) {
            const selectedRow = this.customers[data.row_index]
            if (data.type == "address") {
                if (selectedRow.full_data.user_addresses.length > 0) {
                    this.sidebar_title = 'User Address Details'
                    this.customer_addresses = selectedRow.full_data.user_addresses
                    this.show_details = true
                } else {
                    this.$toast.show('No address found.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
            } else if (data.type == "profile") {
                this.sidebar_title = 'User Details'
                this.customer = { ...selectedRow.full_data }
                delete this.customer.carts
                delete this.customer.user_addresses
                delete this.customer.deletedAt
                this.show_details = true
            } else if (data.type == 'cart') {
                const user_id = selectedRow.full_data.id
                let query = `/get-cart?user_id=${user_id}`
                const response = await this.$axios.get(query)
                console.log(response.data);
                if (response.data.code == 401) {
                    await this.logout()
                }
                if (response.data.cart_data.length) {
                    this.sidebar_title = 'User Cart Details'
                    this.customer_cart_details = response.data.cart_data
                    this.show_details = true
                } else {
                    this.$toast.show('No products added to cart', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
            }
        },
        async openDetails() {
            this.customer = null
            this.customer_addresses = null
            this.customer_cart_details = null
            this.show_details = false
        },
        async changePage(page_no) {
            this.page = page_no
            this.fetchCustomers()
            window.scrollTo(0,0);
        },
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
            this.$router.push('/login')
        },
        async fetchCustomers() {
            let query = `/fetch-customers?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
            if (this.searchText && this.searchText != '') {
                query = query + `&q=${this.searchText}`
            }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.total = response.data.total
            this.customers = response.data.customers.map(cust => {
                return {
                    'customer name': cust.fullname,
                    'address': 'Address',
                    'cart items': cust.carts.length,
                    full_data: cust
                }
            })
        }
    }
}
</script>