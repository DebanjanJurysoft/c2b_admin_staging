<template>
    <div class="product-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="product-tabs">
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
                    <Pagination @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                    <Pagination @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approve_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                    <Pagination @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                </div>
            </div>
            <!-- table  -->
            <Table @openDetails="openDetails" @callFunction="checkWhatIsCalled" v-if="selected_tab.id == 1" :headings="waiting_product_heading" :data_rows="waiting_product_list" />
            <Table @openDetails="openDetails" v-if="selected_tab.id == 2" :headings="approved_product_heading" :data_rows="approve_product_list" />
            <Table @openDetails="openDetails" v-if="selected_tab.id == 3" :headings="rejected_product_heading" :data_rows="rejected_product_list" />
            <!-- bottom pagination  -->
            <Pagination @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <Pagination @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approve_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <Pagination @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <!-- side product details  -->
            <SidebarComponent @openDetails="openDetails" :visible="show_details" :title="'Product Details'" :product_details="selected_product_details"/>
        </div>
        <b-modal id="rejectProductModal" hide-footer no-close-on-backdrop centered :title="modal_title">
            <b-form-textarea
                id="textarea"
                placeholder="Reason for rejection..."
                rows="3"
                v-model="rejection_reason"
                max-rows="6"
            ></b-form-textarea>
            <div class="d-flex text-center py-2">
                <span @click.prevent="rejectProduct" :class="rejection_reason ? 'logout-button' : 'disabled-button'">Reject</span>
            </div>
        </b-modal>
    </div>
</template>

<script>
import Loader from "./loader.vue"
import Pagination from "./pagination.vue"
import SidebarComponent from "./sidebarComponent.vue"
import Table from "./table.vue"
export default {
    components: { Loader, Table, Pagination, SidebarComponent },
    props: ['searchText'],
    data() {
        return {
            loader: false,
            show_details: false,
            selected_tab: {
                id: 1,
                name: 'products_approval',
                text: 'products approval'
            },
            tabs: [
                {
                    id: 1,
                    name: 'products_approval',
                    text: 'products approval'
                },
                {
                    id: 2,
                    name: 'approved_products',
                    text: 'approved products'
                },
                {
                    id: 3,
                    name: 'products_disapproved',
                    text: 'disapproved products'
                },
            ],
            waiting_product_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'product category',
                    icon: 'fa fa-copyright'
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
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            text: null,
                            icon: 'fa fa-ban',
                            color: 'red',
                            emit_name: 'disapprove'
                        },
                        {
                            text: null,
                            icon: 'fa fa-check',
                            color: 'green',
                            emit_name: 'approve'
                        },
                    ]
                },
            ],
            approved_product_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
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
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
            ],
            rejected_product_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
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
                    name: 'date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'time',
                    icon: 'fa fa-clock-o'
                },
            ],
            waiting_product_list: [],
            approve_product_list: [],
            rejected_product_list: [],
            selected_product_id: null,
            selected_category_id: null,
            modal_title: '',
            rejection_reason: null,
            selected_date: null,
            per_page: 7,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            page: 1,
            waiting_product_list_total: 0,
            approve_product_list_total: 0,
            rejected_product_list_total: 0,
            total_rows: 0,
            timer: null,
            selected_product_details: {},
        }
    },
    async mounted() { 
        this.loader = true
        await this.mountedFunction()
        await this.changeTab(0)
        this.loader = false
    },
    watch: {
        per_page() {
            this.changePage(this.page)
        },
        searchText(val) {
            clearTimeout(this.timer)
            this.timer = setTimeout(async () => {
                this.loader = true
                await this.mountedFunction()
                this.loader = false
            }, 300);
        }
    },
    methods: {
        openDetails(data) {
            const index = parseInt(data)
            this.selected_product_details = {}
            if (!this.show_details) {
                if (this.selected_tab.id == 1) {
                    const selectedData = this.waiting_product_list[index]
                    this.selected_product_details = {
                        product_image: 'http://localhost:3030/uploads/categories/Food.svg',
                        product_name: selectedData['product name'],
                        product_price: `₹ ${parseFloat(selectedData.full_data.price).toLocaleString('en-IN')}`,
                        product_quantity: selectedData.full_data.available_stocks ? selectedData.full_data.available_stocks : 1,
                        product_id: selectedData['product id'],
                        product_desc: selectedData.full_data.description,
                        product_colors: selectedData.full_data.color ? [{
                            name: selectedData.full_data.color,
                        }] : null,
                        product_sizes: selectedData.full_data.size ? [{
                            name: selectedData.full_data.size[0].toUpperCase()
                        }] : null,
                        product_specification: selectedData.full_data.specifications ? selectedData.full_data.specifications.split(',') : null,
                        product_negotiation: selectedData.full_data.negotiation ? {
                            heading: 'Negotiation',
                            icon: 'fa fa-commenting-o',
                            text: 'Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.',
                        } : null,
                        product_delivery_types: [
                            {
                                value: true,
                                text: 'SELF PICKUP'
                            },
                            {
                                value: true,
                                text: 'DUNZO DELIVERY'
                            },
                            {
                                value: true,
                                text: 'SELLER DELIVERY'
                            },
                        ],
                        product_store_address: `${selectedData.full_data.vendor.store.add1},${selectedData.full_data.vendor.store.add2 ? ' ' + selectedData.full_data.vendor.store.add2 : ''}, ${selectedData.full_data.vendor.store.area}, ${selectedData.full_data.vendor.store.city}, ${selectedData.full_data.vendor.store.state}, ${selectedData.full_data.vendor.store.landmark}, ${selectedData.full_data.vendor.store.pincode}`
                    }
                } else if (this.selected_tab.id == 2) {
                    const selectedDataA = this.approve_product_list[index]
                    this.selected_product_details = {
                        product_image: 'http://localhost:3030/uploads/categories/Food.svg',
                        product_name: selectedDataA['product name'],
                        product_price: `₹ ${parseFloat(selectedDataA.full_data.price).toLocaleString('en-IN')}`,
                        product_quantity: selectedDataA.full_data.available_stocks ? selectedDataA.full_data.available_stocks : 1,
                        product_id: selectedDataA['product id'],
                        product_desc: selectedDataA.full_data.description,
                        product_colors: selectedDataA.full_data.color ? [{
                            name: selectedDataA.full_data.color,
                        }] : null,
                        product_sizes: selectedDataA.full_data.size ? [{
                            name: selectedDataA.full_data.size[0].toUpperCase()
                        }] : null,
                        product_specification: selectedDataA.full_data.specifications ? selectedDataA.full_data.specifications.split(',') : null,
                        product_negotiation: selectedDataA.full_data.negotiation ? {
                            heading: 'Negotiation',
                            icon: 'fa fa-commenting-o',
                            text: 'Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.',
                        } : null,
                        product_delivery_types: [
                            {
                                value: true,
                                text: 'SELF PICKUP'
                            },
                            {
                                value: true,
                                text: 'DUNZO DELIVERY'
                            },
                            {
                                value: true,
                                text: 'VENDOR DELIVERY'
                            },
                        ],
                        product_store_address: `${selectedDataA.full_data.vendor.store.add1},${selectedDataA.full_data.vendor.store.add2 ? ' ' + selectedDataA.full_data.vendor.store.add2 : ''}, ${selectedDataA.full_data.vendor.store.area}, ${selectedDataA.full_data.vendor.store.city}, ${selectedDataA.full_data.vendor.store.state}, ${selectedDataA.full_data.vendor.store.landmark}, ${selectedDataA.full_data.vendor.store.pincode}`
                    }
                } else if (this.selected_tab.id == 3) { 
                    const selectedDataR = this.rejected_product_list[index]
                    this.selected_product_details = {
                        product_image: 'http://localhost:3030/uploads/categories/Food.svg',
                        product_name: selectedDataR['product name'],
                        product_price: `₹ ${parseFloat(selectedDataR.full_data.price).toLocaleString('en-IN')}`,
                        product_quantity: selectedDataR.full_data.available_stocks ? selectedDataR.full_data.available_stocks : 1,
                        product_id: selectedDataR['product id'],
                        product_desc: selectedDataR.full_data.description,
                        product_colors: selectedDataR.full_data.color ? [{
                            name: selectedDataR.full_data.color,
                        }] : null,
                        product_sizes: selectedDataR.full_data.size ? [{
                            name: selectedDataR.full_data.size[0].toUpperCase()
                        }] : null,
                        product_specification: selectedDataR.full_data.specifications ? selectedDataR.full_data.specifications.split(',') : null,
                        product_negotiation: selectedDataR.full_data.negotiation ? {
                            heading: 'Negotiation',
                            icon: 'fa fa-commenting-o',
                            text: 'Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.',
                        } : null,
                        product_delivery_types: [
                            {
                                value: true,
                                text: 'SELF PICKUP'
                            },
                            {
                                value: true,
                                text: 'DUNZO DELIVERY'
                            },
                            {
                                value: true,
                                text: 'VENDOR DELIVERY'
                            },
                        ],
                        product_store_address: `${selectedDataR.full_data.vendor.store.add1},${selectedDataR.full_data.vendor.store.add2 ? ' '+selectedDataR.full_data.vendor.store.add2 : ''}, ${selectedDataR.full_data.vendor.store.area}, ${selectedDataR.full_data.vendor.store.city}, ${selectedDataR.full_data.vendor.store.state}, ${selectedDataR.full_data.vendor.store.landmark}, ${selectedDataR.full_data.vendor.store.pincode}`
                    }
                }
            }
            this.show_details = !this.show_details
        },
        async mountedFunction() {
            await this.fetchProductsWaitingForApproval()
            await this.fetchApprovedVendors()
            await this.fetchRejectedVendors()
        },
        async changePage(page_no) {
            this.page = page_no
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchProductsWaitingForApproval()
                    break;
                case 2:
                    await this.fetchApprovedVendors()
                    break;
                case 3:
                    await this.fetchRejectedVendors()
                    break;
            }
            window.scrollTo(0,0);
        },
        showModal(modalId) {
            this.$bvModal.show(modalId)
        },
        closeModal(modalId) {
            this.$bvModal.hide(modalId)
        },
        async rejectProduct() {
            const response = await this.$axios({
                method: 'post',
                url: '/reject-product', 
                data: {
                    product_id: this.selected_product_id,
                    category_id: this.selected_category_id,
                    reason: this.rejection_reason
                }
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            this.closeModal('rejectProductModal')
            await this.fetchProductsWaitingForApproval()
            await this.mountedFunction()
        },
        async approveProduct() {
            const response = await this.$axios({
                method: 'post',
                url: '/approve-product', 
                data: {
                    product_id: this.selected_product_id,
                    category_id: this.selected_category_id
                }
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.fetchProductsWaitingForApproval()
            await this.mountedFunction()
        },
        async checkWhatIsCalled(passedData) {
            try {
                const { emitMethod, data } = passedData
                switch (emitMethod) {
                    case "approve":
                        this.selected_product_id = data.full_data.id
                        this.selected_category_id = data.full_data.category_table_association.id
                        await this.approveProduct()
                        break;
                    case "disapprove":
                        this.selected_product_id = data.full_data.id
                        this.selected_category_id = data.full_data.category_table_association.id
                        const product = data.full_data.name
                        this.modal_title = `Rejecting of ${product}`
                        this.showModal('rejectProductModal')
                        break;
                }
                
            } catch (error) {
                this.$toast.show(error.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            }
        },
        async changeTab(index) {
            this.page = 1
            this.loader = true
            switch (index) {
                case 0:
                    await this.fetchProductsWaitingForApproval()
                    this.total_rows = this.waiting_product_list_total
                    break;
                case 1:
                    await this.fetchApprovedVendors()
                    this.total_rows = this.approve_product_list_total
                    break;
                case 2:
                    await this.fetchRejectedVendors()
                    this.total_rows = this.rejected_product_list_total
                    break;
            }
            this.selected_tab = this.tabs[index]
            this.loader = false
        },
        async fetchApprovedVendors() {
            try {
                let query = `/approved-product?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&q=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.approve_product_list = response.data.products.map(e => {
                    return {
                        'vendor name': e.vendor ? e.vendor.fullname : 'N/A',
                        'store name': e.vendor.store ? e.vendor.store.name : 'N/A',
                        'product category': e.category_table_association ? e.category_table_association.category_name : 'N/A',
                        'product name': e.name ? e.name : 'N/A',
                        'product id': e.id ? `${e.category_table_association.category_name}-${e.id}` : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id,
                        full_data: e
                    }
                })
                this.approve_product_list_total = response.data.total
                this.tabs.forEach(e => {
                    if (e.name == 'approved_products') {
                        e.text = `approved products (${response.data.total})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        async fetchRejectedVendors() {
            try {
                let query = `/rejected-product?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&q=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.rejected_product_list = response.data.products.map(e => {
                    return {
                        'vendor name': e.vendor ? e.vendor.fullname : 'N/A',
                        'store name': e.vendor.store ? e.vendor.store.name : 'N/A',
                        'product category': e.category_table_association ? e.category_table_association.category_name : 'N/A',
                        'product name': e.name ? e.name : 'N/A',
                        'product id': e.id ? `${e.category_table_association.category_name}-${e.id}` : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id,
                        full_data: e
                    }
                })
                this.rejected_product_list_total = response.data.total
                this.tabs.forEach(e => {
                    if (e.name == 'products_disapproved') {
                        e.text = `disapproved products (${response.data.total})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async fetchProductsWaitingForApproval() {
            try {
                let query = `/get-products-for-approval?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&q=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.waiting_product_list = response.data.products.map(e => {
                    return {
                        'vendor name': e.vendor ? e.vendor.fullname : 'N/A',
                        'store name': e.vendor.store ? e.vendor.store.name : 'N/A',
                        'product category': e.category_table_association ? e.category_table_association.category_name : 'N/A',
                        'product name': e.name ? e.name : 'N/A',
                        'product id': e.id ? `${e.category_table_association.category_name}-${e.id}` : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id,
                        full_data: e
                    }
                })
                this.waiting_product_list_total = response.data.total
                this.tabs.forEach(e => {
                    if (e.name == 'products_approval') {
                        e.text = `product approval (${response.data.total})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        } 
    }
}
</script>