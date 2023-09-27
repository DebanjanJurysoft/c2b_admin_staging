<template>
    <div class="order-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="order-tabs">
            <div class="tab-items" @click.prevent="changeTab(index)" :class="selected_tab.id == tab.id ? 'tab-items-active' : ''" v-for="(tab, index) in tabs" :key="index">
                <span>{{ tab.text }}</span>
            </div>
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row">
                <div class="w-75">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="payments" :per_page="per_page" :total_rows="payment_total" :page="page"/>
                </div>
            </div>
            <Table @openDetails="openDetails" :headings="payment_heading" :data_rows="payments" />
            <Pagination @changePage="changePage" :data_list="payments" :per_page="per_page" :total_rows="payment_total" :page="page"/>
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="'Product Details'" :product_details="product_details"/>
        </div>
    </div>
</template>
<script>
export default {
    props: ['searchText'],
    data() {
        return {
            loader: false,
            selected_tab: {
                id: 1,
                name: 'unpaid',
                text: 'unpaid'
            },
            tabs: [
                {
                    id: 1,
                    name: 'unpaid',
                    text: 'unpaid'
                },
                {
                    id: 2,
                    name: 'paid',
                    text: 'paid'
                },
            ],
            payments: [],
            payment_heading: [
            {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'order id',
                    icon: 'bx bxs-package',
                    onclick: true
                },
                {
                    name: 'product name',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'product id',
                    icon: 'fa fa-product-hunt',
                    onclick: true
                },
                {
                    name: 'total price',
                    icon: 'fa fa-money'
                },
                {
                    name: 'payment id',
                    icon: 'fa fa-money'
                },
                {
                    name: 'payment ref id',
                    icon: 'fa fa-money'
                },
                {
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
            ],
            payment_total: 0,
            per_page: 7,
            page: 1,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            product_details: null,
            show_details: false,
        }
    },
    async mounted() {
        await this.mountedMethod()
        this.changeTab(0)
    },
    watch: {
        per_page() {
            this.changePage(this.page)
        },
    },
    methods: {
        async openDetails(data) {
            const index = parseInt(data)
            this.product_details = {}
            if (!this.show_details) {
                const selectedData = this.payments[index]
                this.product_details = {
                    product_image: 'http://localhost:3030/uploads/categories/Food.svg',
                    product_name: selectedData['product name'],
                    product_price: selectedData['unit price'],
                    product_quantity: selectedData.full_data.quantity,
                    product_id: selectedData['product id'],
                    product_desc: selectedData.full_data.product.description,
                    product_colors: selectedData.full_data.product.color ? [{
                        name: selectedData.full_data.product.color,
                    }] : null,
                    product_sizes: selectedData.full_data.product.size ? [{
                        name: selectedData.full_data.product.size[0].toUpperCase()
                    }] : null,
                    product_specification: selectedData.full_data.product.specifications ? selectedData.full_data.product.specifications.split(',') : null,
                    product_negotiation: selectedData.full_data.negotiation ? {
                        heading: 'Negotiation',
                        icon: 'fa fa-commenting-o',
                        text: 'Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.',
                    } : null,
                    product_delivery_types: [
                        {
                            text: 'SELF PICKUP'
                        },
                        {
                            text: 'DUNZO DELIVERY'
                        },
                        {
                            text: 'SELLER DELIVERY'
                        },
                    ].map(e => {
                        if (e.text == selectedData.full_data.delivery_type.type) {
                            return {
                                value: true,
                                ...e
                            }
                        } else {
                            return {
                                value: false,
                                ...e
                            }
                        }
                    }),
                }
            }
            this.show_details = !this.show_details
        },
        async changePage(page_no) {
            this.page = page_no
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchUnpaid(false)
                    break;
                case 2:
                    await this.fetchUnpaid(true)
                    break;
            }
            window.scrollTo(0, 0);
            this.loader = false
        },
        async mountedMethod() {
            this.loader = true
            switch (this.selected_tab.id) {
                case 0:
                    await this.fetchUnpaid(false)
                    break;
                case 1:
                    await this.fetchUnpaid(true)
                    break
            }
            this.loader = false
        },
        async changeTab(index) { 
            this.selected_tab = this.tabs[index]
            this.page = 1
            switch (index) {
                case 0:
                    await this.fetchUnpaid(false)
                    break;
                case 1:
                    await this.fetchUnpaid(true)
                    break
            
                default:
                    break;
            }
            this.loader = false
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async fetchUnpaid(is_paid) {
            let query = `/get-unpaid-payments?page=${this.page ? this.page : 1}&per_page=${this.per_page}&is_paid=${is_paid}`
            // if (this.searchText && this.searchText != '') {
            //     query = query + `&q=${this.searchText}`
            // }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.payment_total = response.data.total
            this.payments = response.data.payment_details.map(payment => {
                return {
                    'vendor name': payment.vendor.fullname,
                    'store name': payment.vendor.store.name,
                    'order id': payment.order_id,
                    'product name': payment.product.name,
                    'product id': `${payment.category_table_association.category_name}-${payment.product.id}`,
                    'product category': payment.category_table_association.category_name,
                    'total price': `₹ ${(parseFloat(payment.price)).toLocaleString('en-IN')}`,
                    'payment ref id': payment.payments.ref_id ? payment.payments.ref_id : 'N/A',
                    'date': payment.createdAt ? new Date(payment.createdAt).toLocaleDateString() : 'N/A',
                    'time': payment.createdAt ? new Date(payment.createdAt).toLocaleTimeString() : 'N/A',
                    'payment id': `${payment.payments.payment_type.type}-${payment.payments.id}`,
                    full_data: payment
                }
            })
            this.tabs.forEach(e => {
                if (is_paid === false && e.name == 'unpaid') {
                    e.text = `unpaid (${this.payment_total})`  
                } else if (is_paid === true && e.name == 'paid') {
                    e.text = `paid (${this.payment_total})`  
                }
            })
        },
    }
}
</script>