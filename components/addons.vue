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
            <div class="d-flex flex-row">
                <div class="w-75">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="addon_data" :per_page="per_page" :total_rows="total_addons" :page="page"/>
                </div>
            </div>
            <Table @callFunction="checkWhatIsCalled" :headings="addon_heading" :data_rows="addon_data" />
            <Pagination @changePage="changePage" :data_list="addon_data" :per_page="per_page" :total_rows="total_addons" :page="page"/>
        </div>
    </div>
</template>

<script>
export default {
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
            ],
            addon_heading: [],
            addon_data: [],
            total_addons: 0,
            page: 1,
            per_page: 7,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
        }
    },
    async mounted() {
        this.loader = true
        await this.mountedMethod()
        this.loader = false
    },
    watch: {
        per_page() {
            this.page = 0
            this.fetchDataForPage()
        },
    },
    methods: {
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
            switch (this.selected_tab.id) {
                case 1:
                    const addons = await this.fetchAddons(false, this.page, this.per_page)
                    this.total_addons = addons.total
                    const mappedAddons = addons.addons.map(addon => {
                        return {
                            'Vendor Name': addon.vendor.fullname,
                            'Store Name': addon.vendor.store.name,
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
                        {
                            name: 'Vendor Name',
                            icon: 'fa fa-user-o',
                        },
                        {
                            name: 'Store Name',
                            icon: 'fa fa-user-o',
                        },
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
                                    text: null,
                                    icon: 'fa fa-check',
                                    color: 'green',
                                    emit_name: 'approve'
                                },
                            ]
                        },
                    ]
                    break;
            
                case 2: 
                    const approvedAddons = await this.fetchAddons(true, this.page, this.per_page)
                    this.total_addons = approvedAddons.total
                    const mappedApprovedAddons = approvedAddons.addons.map(addon => {
                        return {
                            'Vendor Name': addon.vendor.fullname,
                            'Store Name': addon.vendor.store.name,
                            'Addon Name': addon.name,
                            'Price': `₹ ${addon.price}`,
                            'Compare Price': `₹ ${addon.compared_price}`,
                            'Date': new Date(addon.createdAt).toLocaleDateString(),
                            'Time': new Date(addon.createdAt).toLocaleTimeString(),
                            full_data: addon
                        }
                    })
                    const approvedAddonData = await Promise.all(mappedApprovedAddons)
                    this.addon_data = approvedAddonData
                    this.addon_heading = [
                        {
                            name: 'Vendor Name',
                            icon: 'fa fa-user-o',
                        },
                        {
                            name: 'Store Name',
                            icon: 'fa fa-user-o',
                        },
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
                    ]
                    break
            }
            window.scrollTo(0,0);
        },
        async fetchAddons(approve, page = 1, per_page = 7) {
            try {
                let path = `/fetch-add-ons?approve=${approve}`
                if (page) {
                    path += `&page=${page}`
                }
                if (per_page) {
                    path += `&per_page=${per_page}`
                }
                const response = await this.$axios.get(path)
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