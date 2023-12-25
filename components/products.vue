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
                <div class="d-flex flex-fill flex-row align-items-center mb-3">
                    <div class="w-75" v-if="selected_tab.id != 4">
                        <div class="d-flex flex-row align-items-center" style="gap: 10px">
                            <label class="mr-3">Rows:</label>
                            <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                            <button class="button" @click.prevent="reloadData"><i class="fa fa-refresh"></i></button>
                            <b-form-select 
                                @input="filterCategory"
                                style="width: max-content;"
                                v-model="selectecd_category_filter" 
                                value-field="id"
                                text-field="category_name"
                                :options="category_list_filter"
                            ></b-form-select>
                            <b-form-select 
                                @input="filterCategory"
                                style="width: max-content;"
                                v-model="selected_vendor" 
                                value-field="id"
                                text-field="fullname"
                                :options="vendor_list"
                            ></b-form-select>
                        </div>
                    </div>
                    <div class="w-25 d-flex flex-row-reverse align-items-center" v-if="selected_tab.id != 4">
                        <button class="button mx-2" @click.prevent="addEditProduct('Add Product')"><i class="fa fa-plus mr-2"></i> Add</button>
                    </div>
                </div>
                <div class="d-flex flex-row-reverse ml-3">
                    <div>
                        <!-- top pagination  -->
                        <Pagination @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                        <Pagination @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approve_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                        <Pagination @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_product_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                    </div>
                </div>
            </div>
            <!-- table  -->
            <Table @openDetails="openDetails" @callFunction="checkWhatIsCalled" v-if="selected_tab.id == 1" :headings="waiting_product_heading" :file_name="'waiting_products_list.csv'" :data_rows="waiting_product_list" :page="page" :rows="per_page"/>
            <Table @openSpecific="openSpecific" @callFunction="checkWhatIsCalled" @openDetails="openDetails" v-if="selected_tab.id == 2" :headings="approved_product_heading" :data_rows="approve_product_list" :file_name="'approve_product_list.csv'" :page="page" :rows="per_page" />
            <Table @openDetails="openDetails" v-if="selected_tab.id == 3" :headings="rejected_product_heading" :data_rows="rejected_product_list" :file_name="'rejected_product_list.csv'" :page="page" :rows="per_page" />
            <BulkUploadProducts @reloadData="reloadData" v-if="selected_tab.id == 4" />
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
        <ProductAdd :edit_data="edit_data" :product_data="product_update_data" :visible="add_edit_product" :title="form_title" @closeSidebar="closeSidebar" @openDetails="addEditProduct"/>
        <!-- <ProductAdd2 v-else :visible="add_edit_product" :product_data="product_update_data" :title="form_title" @closeSidebar="closeSidebar" @openDetails="addEditProduct"/> -->
    </div>
</template>

<script>
import Loader from "./loader.vue"
import ProductAdd from "./product_adding_form.vue"
import Pagination from "./pagination.vue"
import SidebarComponent from "./sidebarComponent.vue"
import BulkUploadProducts from "./bulkUploadProducts.vue"
import Table from "./table.vue"
export default {
    components: { Loader, Table, Pagination, SidebarComponent, ProductAdd, BulkUploadProducts },
    props: ['searchText'],
    data() {
        return {
            edit_data: false,
            form_title: '',
            add_edit_product: false,
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
                {
                    id: 4,
                    name: 'bulk_upload_product',
                    text: 'bulk upload products'
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
                    name: 'created date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'created time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'updated date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'updated time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'open time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'close time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            text: 'Edit',
                            icon: 'fa fa-pencil',
                            color: 'orange',
                            emit_name: 'Edit',
                            border: 'none'
                        },
                        {
                            text: 'Disapprove',
                            icon: 'fa fa-ban',
                            color: 'red',
                            emit_name: 'disapprove',
                            border: 'none'
                        },
                        {
                            text: 'Approve',
                            icon: 'fa fa-check',
                            color: 'green',
                            emit_name: 'approve',
                            border: 'none'
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
                    name: 'Active',
                    icon: 'fa fa-eye',
                    type: 'SWITCH',
                    onclick: true,
                    onclick_emit: 'is_active'
                },
                {
                    name: 'created date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'created time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'updated date',
                    icon: 'fa fa-calendar-o'
                },
                {
                    name: 'updated time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'open time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'close time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            text: 'Edit',
                            icon: 'fa fa-pencil',
                            color: 'orange',
                            emit_name: 'Edit',
                            border: 'none'
                        },
                    ]
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
                {
                    name: 'has time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'open time',
                    icon: 'fa fa-clock-o'
                },
                {
                    name: 'close time',
                    icon: 'fa fa-clock-o'
                },
            ],
            waiting_product_list: [],
            vendor_list: [],
            selected_vendor: null,
            approve_product_list: [],
            rejected_product_list: [],
            category_list_filter: [],
            selectecd_category_filter: null,
            selected_product_id: null,
            selected_category_id: null,
            modal_title: '',
            rejection_reason: null,
            selected_date: null,
            per_page: 5,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            page: 1,
            waiting_product_list_total: 0,
            approve_product_list_total: 0,
            rejected_product_list_total: 0,
            total_rows: 0,
            timer: null,
            selected_product_details: {},
            product_update_data: null
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
        async fetchApprovedVendorsData() {
            try {
                let query = `/approved-vendor`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.vendor_list = response.data.vendors.map(e => {
                    return {
                        ...e,
                        fullname: `${e.fullname} (${e.store.name})`
                    }
                })
                this.vendor_list.unshift({
                    id: null,
                    fullname: 'Select a vendor'
                })
            } catch (error) {
                console.log(error);
            }
        },
        reloadData() {
            if (this.selected_tab.id == 4) {
                this.mountedFunction()
            }
            this.changeTab(this.tabs.indexOf(this.selected_tab))
            this.$emit('reloadDashboard')
        },
        async filterCategory() { 
            this.loader = true
            await this.mountedFunction()
            await this.changeTab(this.tabs.indexOf(this.selected_tab))
            this.loader = false
        },
        async closeSidebar() {
            this.add_edit_product = false
            this.product_update_data = null
            this.edit_data = false
            await this.mountedFunction()
        },
        async addEditProduct(title = null) {
            this.form_title = title ? title : 'Add Product'
            this.edit_data = title.includes('Edit') ? true : false
            this.add_edit_product = true
        },
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
                        product_image: selectedData.full_data.category_table_association.image,
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
                        product_image: selectedDataA.full_data.category_table_association.image,
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
                        product_image: selectedDataR.full_data.category_table_association.image,
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
            await this.fetchCategoryList()
            await this.fetchApprovedVendorsData()
            this.$emit('reloadDashboard')
        },
        openSpecific(data) {
            if (data.type == 'is_active') {
                this.active_inactive(data)
            }
        },
        async active_inactive(data) {
            this.loader = true
            const response = await this.$axios.post('/active-inactive-product', {
                category_id: data.data.full_data.category_id,
                product_id: data.data.full_data.id,
                is_active: data.data['Active']
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.changePage(this.page)
            this.loader = false
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
            this.rejection_reason = null
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
                    case 'Edit': 
                        const product_data = data.full_data
                        this.product_update_data = product_data
                        this.addEditProduct('Edit Product')
                        break
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
                if (this.selected_vendor) {
                    query = query + `&vendor_id=${this.selected_vendor}`
                }
                if (this.searchText && this.searchText != '') {
                    query = query + `&q=${this.searchText}`
                }
                if (this.selectecd_category_filter) {
                    const cat = this.category_list_filter.find(e => e.id == this.selectecd_category_filter).category_name
                    query = query + `&category_name=${cat.replace('&', '%26')}`
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
                        'Active': e.is_active ? true : false,
                        'created date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'created time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        'updated date': e.updatedAt ? new Date(e.updatedAt).toLocaleDateString() : 'N/A',
                        'updated time': e.updatedAt ? new Date(e.updatedAt).toLocaleTimeString() : 'N/A',
                        // 'has time': e.has_time != null ? String(e.has_time) : 'N/A',
                        'open time': e.open_time != null ? e.open_time : 'N/A',
                        'close time': e.close_time != null ? e.close_time : 'N/A',
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
                if (this.selected_vendor) {
                    query = query + `&vendor_id=${this.selected_vendor}`
                }
                if (this.searchText && this.searchText != '') {
                    query = query + `&q=${this.searchText}`
                }
                if (this.selectecd_category_filter) {
                    const cat = this.category_list_filter.find(e => e.id == this.selectecd_category_filter).category_name
                    query = query + `&category_name=${cat.replace('&', '%26')}`
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
                        'has time': e.has_time != null ? String(e.has_time) : 'N/A',
                        'open time': e.open_time != null ? e.open_time : 'N/A',
                        'close time': e.close_time != null ? e.close_time : 'N/A',
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
                if (this.selected_vendor) {
                    query = query + `&vendor_id=${this.selected_vendor}`
                }
                if (this.searchText && this.searchText != '') {
                    query = query + `&q=${this.searchText}`
                }
                if (this.selectecd_category_filter) {
                    const cat = this.category_list_filter.find(e => e.id == this.selectecd_category_filter).category_name
                    query = query + `&category_name=${cat.replace('&', '%26')}`
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
                        'created date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'created time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        'updated date': e.updatedAt ? new Date(e.updatedAt).toLocaleDateString() : 'N/A',
                        'updated time': e.updatedAt ? new Date(e.updatedAt).toLocaleTimeString() : 'N/A',
                        // 'has time': e.has_time != null ? String(e.has_time) : 'N/A',
                        'open time': e.open_time != null ? e.open_time : 'N/A',
                        'close time': e.close_time != null ? e.close_time : 'N/A',
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
        },
        async fetchCategoryList() {
            try {
                const path = '/get-categories-and-services'
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.category_list_filter = response.data.categories
                this.category_list_filter.unshift({
                    id: null,
                    category_name: 'Select a category to filter'
                })
            } catch (error) {
                console.log(error);
            }
        }
    }
}
</script>