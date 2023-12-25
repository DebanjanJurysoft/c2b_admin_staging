<template>
    <div class="banner-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="banner-tabs">
            <div class="tab-items" @click.prevent="changeTab(index)" :class="selected_tab.id == tab.id ? 'tab-items-active' : ''" v-for="(tab, index) in tabs" :key="index">
                <span>{{ tab.text }}</span>
            </div>
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row align-items-center">
                <div v-if="selected_tab.id == 1 || selected_tab.id == 2" class="w-75 d-flex flex-row align-items-center" style="gap: 10px;">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                    <button class="button" @click.prevent="fetchDataForPage"><i class="fa fa-refresh"></i></button>
                    <button class="button" @click.prevent="openAddModal"><i class="fa fa-plus mr-2"></i>Add</button>
                    <button class="button" @click.prevent="openMapWithProductModal"><i class="fa fa-connectdevelop mr-2"></i>Map With Product</button>
                </div>
                <div class="w-25" v-if="selected_tab.id == 1 || selected_tab.id == 2">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="addon_data" :per_page="per_page" :total_rows="total_addons" :page="page"/>
                </div>
            </div>
            <Table v-if="selected_tab.id == 1 || selected_tab.id == 2" @callFunction="checkWhatIsCalled" @openSpecific="openSpecific" :headings="addon_heading" :data_rows="addon_data" :file_name="`${selected_tab.name}_list.csv`" :page="page" :rows="per_page"/>
            <Pagination v-if="selected_tab.id == 1 || selected_tab.id == 2" @changePage="changePage" :data_list="addon_data" :per_page="per_page" :total_rows="total_addons" :page="page"/>
            <b-modal id="addEditAddons" hide-footer hide-header no-close-on-backdrop centered>
                <div class="d-flex flex-row align-items-center justify-content-between">
                    <span class="text-heading" style="font-size: 25px !important; padding-left: 0px !important;">{{ modal_title }}</span>
                    <span class="text-heading text-danger cursor-pointer" @click.prevent="closeAddModal" style="font-size: 15px !important;"><i class="fa fa-times mr-2"></i>Close</span>
                </div>
                <div class="d-flex flex-column py-3" style="gap: 15px !important;">
                    <div class="d-flex flex-row w-100 align-items-center">
                        <div class="w30">
                            <span class="text-heading" style="font-size: 15px;">Vendor: </span>
                        </div>
                        <div class="w70">
                            <b-form-select
                                style="width: 100% !important;"
                                value-field="id"
                                text-field="fullname"
                                v-model="selected_vendor"
                                :options="vendor_list">
                            </b-form-select>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100 align-items-center">
                        <div class="w30">
                            <span class="text-heading" style="font-size: 15px;">Name: </span>
                        </div>
                        <div class="w70">
                            <b-form-input v-model="addon_name" placeholder="Addon Name"></b-form-input>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100 align-items-center">
                        <div class="w30">
                            <span class="text-heading" style="font-size: 15px;">Price: </span>
                        </div>
                        <div class="w70">
                            <b-form-input v-model="price" placeholder="Price"></b-form-input>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100 align-items-center">
                        <div class="w30">
                            <span class="text-heading" style="font-size: 15px;">Compare Price: </span>
                        </div>
                        <div class="w70">
                            <b-form-input v-model="compared_price" placeholder="Compare Price"></b-form-input>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100 align-items-center">
                        <div class="w30">
                            <span class="text-heading" style="font-size: 15px;">GST (%): </span>
                        </div>
                        <div class="w70">
                            <b-form-input v-model="gst" placeholder="GST (%)"></b-form-input>
                        </div>
                    </div>
                    <div class="d-flex flex-row w-100 justify-content-center">
                        <button class="button" @click.prevent="saveAddons"><i class="fa fa-save mr-2"></i>Save</button>
                    </div>
                </div>
            </b-modal>
            <b-modal id="MapWithProduct" size="lg" hide-footer hide-header no-close-on-backdrop>
                <div class="d-flex flex-row align-items-center justify-content-between">
                    <span class="text-heading" style="font-size: 25px !important; padding-left: 0px !important;">{{ modal_title }}</span>
                    <span class="text-heading text-danger cursor-pointer" @click.prevent="closeMapWithProductModal" style="font-size: 15px !important;"><i class="fa fa-times mr-2"></i>Close</span>
                </div>
                <div class="d-flex flex-column mt-4 px-2">
                    <div class="d-flex flex-row w-100 align-items-center">
                        <div class="w30">
                            <span class="text-heading" style="font-size: 15px;">Vendor: </span>
                        </div>
                        <div class="w70">
                            <b-form-select
                                style="width: 100% !important;"
                                value-field="id"
                                @change="fetchProductAndAddons(selected_vendor)"
                                text-field="fullname"
                                v-model="selected_vendor"
                                :options="vendor_list">
                            </b-form-select>
                        </div>
                    </div>
                    <div class="d-flex flex-row mt-3" v-if="selected_vendor">
                        <div class="d-flex flex-row w50 align-items-center">
                            <div class="w30">
                                <span class="text-heading" style="font-size: 15px;">Products: </span>
                            </div>
                            <div class="w70">
                                <vSelect 
                                    multiple
                                    v-model="selected_products_for_vendor"
                                    :label="'name'"
                                    :options="product_list_for_vendor"
                                ></vSelect>
                            </div>
                        </div>
                        <div class="d-flex flex-row w50 align-items-center">
                            <div class="w30">
                                <span class="text-heading" style="font-size: 15px;">Addons: </span>
                            </div>
                            <div class="w70">
                                <vSelect 
                                    multiple
                                    v-model="selected_addons_for_vendor"
                                    :label="'name'"
                                    :options="addon_list_for_vendor"
                                ></vSelect>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-row justify-content-center" v-if="selected_vendor && (selected_addons_for_vendor.length || selected_products_for_vendor.length)">
                        <button class="button" @click.prevent="saveAddonMapes"><i class="fa fa-save mr-2"></i>Save</button>
                    </div>
                    <div class="card mt-3" v-if="selected_vendor && (selected_addons_for_vendor.length || selected_products_for_vendor.length)" style="height: 400px !important; overflow-y: auto !important;">
                        <div class="w100" v-for="(product, product_index) in selected_products_for_vendor">
                            <div class="card d-flex flex-row align-items-center px-5 py-3" style="gap: 15px !important;">
                                <div class="card w30" style="height: max-content !important;" v-if="selected_products_for_vendor.length">
                                    <span class="text-heading text-success">{{ product.name }}</span>
                                </div>
                                <div class="w30 d-flex flex-column align-items-center">
                                    <span class="text-heading text-success" v-if="selected_products_for_vendor.length"><i class="fa fa-long-arrow-left mr-3" aria-hidden="true"></i>Products</span>
                                    <span class="text-heading text-primary" v-if="selected_addons_for_vendor.length">Addons<i class="fa fa-long-arrow-right ml-3" aria-hidden="true"></i></span>
                                </div>
                                <div class="d-flex flex-column w30" style="gap: 15px !important;" v-if="selected_addons_for_vendor.length">
                                    <div class="w100 card" v-for="(addon, addon_index) in selected_addons_for_vendor">
                                        <span class="text-heading text-primary">{{ addon.name }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </b-modal>
            <div class="d-flex flex-column" v-if="selected_tab.id == 3">
                <div class="d-flex flex-column mt-3" style="height: 600px !important; overflow-y: auto !important;">
                    <div class="w100" v-for="(product, product_index) in mapping_data.products">
                        <div class="card d-flex flex-row align-items-center px-5 py-3" style="gap: 15px !important;">
                            <div class="card w30" style="height: max-content !important;">
                                <span class="text-heading text-success">{{ product.name }}</span>
                            </div>
                            <div class="w30 d-flex flex-column align-items-center">
                                <span class="text-heading text-success"><i class="fa fa-long-arrow-left mr-3" aria-hidden="true"></i>Products</span>
                                <span class="text-heading text-primary">Addons<i class="fa fa-long-arrow-right ml-3" aria-hidden="true"></i></span>
                            </div>
                            <div class="d-flex flex-column w30" style="gap: 15px !important;">
                                <div class="w100 border rounded d-flex flex-row justify-content-between" v-for="(addon, addon_index) in mapping_data.addOns" :key="addon_index" v-if="mapping_data.productData.find(e => e.product_id == product.id && e.category_id == product.category_id && e.addon_id == addon.id)" >
                                    <span v-if="mapping_data.productData.find(e => e.product_id == product.id && e.category_id == product.category_id && e.addon_id == addon.id)" class="text-heading text-primary w90">{{ addon.name }}</span>
                                    <button class="btn btn-outline-danger w10" style="width: max-content !important;" @click.prevent="deleteAddOnFromProduct(mapping_data.productData.find(e => e.product_id == product.id && e.category_id == product.category_id && e.addon_id == addon.id))"><i class="fa fa-times"></i></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
    components: { vSelect },
    data() { 
        return {
            loader: false,
            selected_tab: {
                id: 1,
                name: 'addon_approval',
                text: 'addons approval'
            },
            tabs: [
                {
                    id: 1,
                    name: 'addon_approval',
                    text: 'addons approval'
                },
                {
                    id: 2,
                    name: 'approved_addons',
                    text: 'approved addons'
                },
                {
                    id: 3,
                    name: 'product_addon_map',
                    text: 'products addons mapping'
                },
            ],
            addon_heading: [],
            addon_data: [],
            total_addons: 0,
            page: 1,
            per_page: 5,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            modal_title: 'Add Addons',
            vendor_list: [],
            selected_vendor: null,
            addon_name: null,
            price: null,
            gst: null,
            compared_price: null,
            product_list_for_vendor: [],
            selected_products_for_vendor: [],
            addon_list_for_vendor: [],
            selected_addons_for_vendor: [],
            mapping_data: {
                addOns: [],
                productData: [],
                products: [],
                selected_product: null,
                selected_addon: null,
            }
        }
    },
    async mounted() {
        this.loader = true
        await this.mountedMethod()
        this.loader = false
    },
    props: ['searchText'],
    watch: {
        searchText(val) {
            clearTimeout(this.timer)
            this.timer = setTimeout(async () => {
                this.loader = true
                await this.mountedMethod()
                this.loader = false
            }, 300);
        },
        per_page() {
            this.page = 0
            this.fetchDataForPage()
        },
    },
    methods: {
        async deleteAddOnFromProduct(data) {
            await this.deleteWithPopup('/remove-addon-from-product', 'addon_association_id', data.id)
        },
        async deleteWithPopup(path, key, data_id) {
            try {
                const h = this.$createElement
                const id = `DeleteModal${id}`
                this.$bvToast.hide(id)
                const $closeButton = h(
                'b-button',
                {
                    on: { click: () => this.$bvToast.hide(id) },
                    class: 'btn btn-primary mx-1',
                    style: 'margin: 0 auto;'
                },
                'No'
                )
                const $acceptButton = h(
                'b-button',
                {
                    on: {
                        click: async () => {
                            let data = {}
                            data[key] = data_id
                            const deleteresponse = await this.$axios.post(path, data)
                            await this.fetchMappingData()
                            this.$toast.show(deleteresponse.data.message, {
                                duration: 1500,
                                position: 'top-right',
                                keepOnHover: true,
                                type: deleteresponse.data.status
                            })
                            this.$bvToast.hide(id)
                        }
                    },
                    class: 'btn btn-danger mx-1',
                },
                'Yes'
                )
                const $buttonContainer = h(
                    'div',
                    {
                        class: 'text-center my-2',
                    },
                    [$closeButton, $acceptButton]
                )
                this.$bvToast.toast($buttonContainer, {
                    id: id,
                    title: `Are you sure?`,
                    noCloseButton: true,
                })
            } catch (error) {
                console.log(error);
            }
        },
        async openSpecific(data) {
            if (data.type == 'enable_disable') {
                // this.banner_in_app(data.data.full_data.id, data.data['show in app'])
                console.log(data);
                const sendDData = {
                    vendor_id: data.data.full_data.vendor_id,
                    addon_id: data.data.full_data.id,
                    name: data.data.full_data.name,
                    price: data.data.full_data.price,
                    compare_price: data.data.full_data.compared_price,
                    gst: data.data.full_data.gst,
                    available: data.data['Available']
                }
                const response = await this.$axios({
                    method: 'POST',
                    url: '/edit-add-on',
                    data: sendDData
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
            }
        },
        async saveAddonMapes() {
            try {
                const path = '/map-product-with-addons'
                const data = {
                    products: this.selected_products_for_vendor.map(e => {
                        return {
                            product_id: e.id,
                            category_id: e.category_id
                        }
                    }),
                    addons: this.selected_addons_for_vendor.map(e => {
                        return {
                            addon_id: e.id,
                        }
                    })
                }
                const response = await this.$axios.post(path, data)
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
            } catch (error) {
                console.log(error);
            }
        },
        async openMapWithProductModal() {
            this.modal_title = 'Map With Product'
            await this.fetchApprovedVendors()
            this.$bvModal.show('MapWithProduct')
        },
        async closeMapWithProductModal() {
            this.selected_vendor = null
            this.vendor_list = []
            this.selected_addons_for_vendor = []
            this.selected_products_for_vendor = []
            this.addon_list_for_vendor = []
            this.product_list_for_vendor = []
            this.$bvModal.hide('MapWithProduct')
        },
        async saveAddons() {
            try {
                const data = {
                    vendor_id: this.selected_vendor,
                    name: this.addon_name,
                    price: this.price,
                    compare_price: this.compared_price,
                    gst: this.gst,
                    available: true,
                }
                const response = await this.$axios.post('/create-new-add-on', data)
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.mountedMethod()
                this.closeAddModal()
            } catch (error) {
                console.log(error);
            }
        },
        async openAddModal() {
            await this.fetchApprovedVendors()
            this.$bvModal.show('addEditAddons')
        },
        closeAddModal() {
            this.vendor_list = []
            this.selected_vendor = null
            this.addon_name = null
            this.price = null
            this.compared_price = null
            this.gst = null
            this.$bvModal.hide('addEditAddons')
        },
        async fetchProductAndAddons(id) {
            await this.fetchApprovedProducts(id)
            await this.fetchApprovedAddons(id)
        },
        async fetchApprovedProducts(id) {
            try {
                let query = `/approved-product?vendor_id=${id}`
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                if (response.data.total == 0) {
                    this.closeMapWithProductModal()
                    this.$toast.show('Please add products for this vendor.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                this.product_list_for_vendor = response.data.products
            } catch (error) {
                console.log(error);
            }
        },
        async fetchApprovedAddons(id) {
            try {
                let path = `/fetch-add-ons?approve=true&vendor_id=${id}`
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                if (response.data.totalAddOns == 0) {
                    this.closeMapWithProductModal()
                    this.$toast.show('Please add addon for this vendor.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                this.addon_list_for_vendor = response.data.addOns
            } catch (error) {
                console.log(error);
            }
        },
        async fetchApprovedVendors() {
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
        changePage(page) { 
            this.page = page
            this.fetchDataForPage()
        },
        async checkWhatIsCalled(passedData) {
            try {
                const { emitMethod, data } = passedData
                switch (emitMethod) {
                    case "approve":
                        const path = '/approve-add-on'
                        const response = await this.$axios.post(path, {
                            addon_id: data.full_data.id,
                        })
                        this.$toast.show(response.data.message, {
                            duration: 1500,
                            position: 'top-right',
                            keepOnHover: true,
                            type: response.data.status
                        })
                        await this.mountedMethod()
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
        changeTab(index) {
            this.selected_tab = this.tabs[index]
            this.page_number = 1
            this.fetchDataForPage()
        },
        async fetchDataForPage() { 
            this.loader = true
            switch (this.selected_tab.id) {
                case 1:
                    const addons = await this.fetchAddons(false, this.page, this.per_page)
                    this.total_addons = addons.total
                    const mappedAddons = addons.addons.map(addon => {
                        return {
                            // 'Vendor Name': addon.vendor.fullname,
                            // 'Store Name': addon.vendor.store.name,
                            'Addon Name': addon.name,
                            'Price': `₹ ${addon.price}`,
                            'Compare Price': `₹ ${addon.compared_price}`,
                            'Date': new Date(addon.createdAt).toLocaleDateString(),
                            'Time': new Date(addon.createdAt).toLocaleTimeString(),
                            full_data: addon
                        }
                    })
                    const addonData = await Promise.all(mappedAddons)
                    this.addon_data = addonData
                    this.addon_heading = [
                        // {
                        //     name: 'Vendor Name',
                        //     icon: 'fa fa-user-o',
                        // },
                        // {
                        //     name: 'Store Name',
                        //     icon: 'fa fa-user-o',
                        // },
                        {
                            name: 'Addon Name',
                            icon: 'fa fa-mobile',
                        },
                        {
                            name: 'Price',
                            icon: 'fa fa-window-maximize',
                        },
                        {
                            name: 'Compare Price',
                            icon: 'fa fa-eye',
                        },
                        {
                            name: "Date",
                            icon: 'fa fa-eye',
                        },
                        {
                            name: "Time",
                            icon: 'fa fa-eye',
                        },
                        {
                            name: 'action',
                            icon: 'fa fa-cog',
                            buttons: [
                                {
                                    emit_name: 'approve',
                                    icon: 'fa fa-check',
                                    text: 'Approve',
                                    color: 'green',
                                    border: 'none',
                                },
                            ]
                        },
                    ]
                    break;
            
                case 3:
                    await this.fetchMappingData() 
                    break
                case 2: 
                    const approvedAddons = await this.fetchAddons(true, this.page, this.per_page)
                    this.total_addons = approvedAddons.total
                    const mappedApprovedAddons = approvedAddons.addons.map(addon => {
                        console.log(addon);
                        return {
                            // 'Vendor Name': addon.vendor.fullname,
                            // 'Store Name': addon.vendor.store.name,
                            'Addon Name': addon.name,
                            'Price': `₹ ${addon.price}`,
                            'Compare Price': `₹ ${addon.compared_price}`,
                            'Available': Boolean(addon.available),
                            'Date': new Date(addon.createdAt).toLocaleDateString(),
                            'Time': new Date(addon.createdAt).toLocaleTimeString(),
                            full_data: addon
                        }
                    })
                    const approvedAddonData = await Promise.all(mappedApprovedAddons)
                    this.addon_data = approvedAddonData
                    this.addon_heading = [
                        // {
                        //     name: 'Vendor Name',
                        //     icon: 'fa fa-user-o',
                        // },
                        // {
                        //     name: 'Store Name',
                        //     icon: 'fa fa-user-o',
                        // },
                        {
                            name: 'Addon Name',
                            icon: 'fa fa-mobile',
                        },
                        {
                            name: 'Price',
                            icon: 'fa fa-window-maximize',
                        },
                        {
                            name: 'Compare Price',
                            icon: 'fa fa-eye',
                        },
                        {
                            name: 'Available',
                            icon: 'fa fa-eye',
                            type: 'SWITCH',
                            onclick: true,
                            onclick_emit: 'enable_disable'
                        },
                        {
                            name: "Date",
                            icon: 'fa fa-eye',
                        },
                        {
                            name: "Time",
                            icon: 'fa fa-eye',
                        },
                    ]
                    break
            }
            this.$emit('reloadDashboard')
            window.scrollTo(0, 0);
            this.loader = false
        },
        async fetchMappingDataForProduct(product_id, category_id) {
            try {
                let query = `/fetch-mapped-product-with-addons?product_id=${product_id}&category_id=${category_id}`
                const response = await this.$axios.get(query)
                console.log(response);
            } catch (error) {
                console.log(error);
            }
        },
        async fetchMappingData() {
            try {
                let query = '/fetch-mapped-product-with-addons'
                const response = await this.$axios.get(query)
                this.mapping_data.addOns = response.data.addOns
                this.mapping_data.productData = response.data.productData
                this.mapping_data.products = response.data.products
            } catch (error) {
                console.log(error);
            }
        },
        async fetchAddons(approve, page = 1, per_page = 7) {
            try {
                let path = `/fetch-add-ons?approve=${approve}`
                if (this.searchText) {
                    path += `&q=${this.searchText}`
                }
                if (page) {
                    path += `&page=${page}`
                }
                if (per_page) {
                    path += `&per_page=${per_page}`
                }
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                return {addons: response.data.addOns, total: response.data.totalAddOns}
            } catch (error) {
                console.log(error);
            }
        },
        async mountedMethod() {
            const waitingAddons = await this.fetchAddons(false, 1, 7)
            const approvedAddon = await this.fetchAddons(true, 1, 7)
            this.tabs[0].text = `addons approval (${waitingAddons.total})`
            this.tabs[1].text = `approved addons (${approvedAddon.total})`
            await this.fetchDataForPage()
        }
    }    
}
</script>