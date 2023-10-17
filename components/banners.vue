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
                    <Pagination @changePage="changePage" :data_list="banners" :per_page="per_page" :total_rows="total_banners" :page="page_number"/>
                </div>
            </div>
            <Table @openSpecific="openSpecific" @callFunction="checkWhatIsCalled" :headings="banner_headings" :data_rows="banners" :file_name="export_file"/>
            <Pagination @changePage="changePage" :data_list="banners" :per_page="per_page" :total_rows="total_banners" :page="page_number"/>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            loader: false,
            banners: [],
            export_file: null,
            selected_tab: {
                id: 1,
                name: 'banner_approval',
                text: 'banners approval'
            },
            tabs: [
                {
                    id: 1,
                    name: 'banner_approval',
                    text: 'banners approval'
                },
                {
                    id: 2,
                    name: 'approved_banners',
                    text: 'approved banners'
                },
            ],
            banner_headings: [],
            total_banners: null,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            per_page: 7,
            page_number: 1
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchBannerCount()
        await this.fetchBanners()
        this.loader = false
    },
    watch: {
        per_page() {
            this.changePage(this.page)
        },
    },
    methods: {
        async checkWhatIsCalled(passedData) {
            try {
                const { emitMethod, data } = passedData
                switch (emitMethod) {
                    case "approve":
                        const path = '/approve-banner-by-admin'
                        const response = await this.$axios.post(path, {
                            banner_id: data.full_data.id,
                        })
                        await this.fetchBannerCount()
                        await this.fetchBanners()   
                        this.$toast.show(response.data.message, {
                            duration: 1500,
                            position: 'top-right',
                            keepOnHover: true,
                            type: response.data.status
                        })
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
        async fetchBannerCount() {
            let approvedquery = `/fetch-approved-banners-for-admin?page_number=${this.page_number ? this.page_number : 1}&per_page=${this.per_page}`
            const approvedResponse = await this.$axios.get(approvedquery)
            let query = `/fetch-waiting-banners-for-admin?page_number=${this.page_number ? this.page_number : 1}&per_page=${this.per_page}`
            const response = await this.$axios.get(query)
            if (response.data.code == 401 || approvedResponse.data.code == 401) {
                await this.logout()
            }
            const bannersWaiting = response.data.banner_total
            const bannersApproved = approvedResponse.data.banner_total
            this.tabs[0].text = `banners approval (${bannersWaiting})`
            this.tabs[1].text = `approved banners (${bannersApproved})`
        },
        async changePage(page_no) {
            this.page_number = page_no
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchBanners()
                    break;
                case 2:
                    await this.fetchApprovedBanners()
                    break;
                // case 3:
                //     await this.fetchRejectedVendors()
                //     break;
            }
            window.scrollTo(0,0);
        },
        changeTab(index) {
            this.selected_tab = this.tabs[index]
            this.page_number = 1
            this.changePage()
        },
        openSpecific(data) {
            if (data.type == 'show_app') {
                this.banner_in_app(data.data.full_data.id, data.data['show in app'])
            }
            if (data.type == 'today_offer') {
                this.bannerToday(data.data.full_data.id, data.data["today's offer"])
            }
        },
        async fetchApprovedBanners() {
            let query = `/fetch-approved-banners-for-admin?page_number=${this.page_number ? this.page_number : 1}&per_page=${this.per_page}`
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.total_banners = response.data.banner_total
            const mapped_banner = response.data.banners.map(banner => {
                return {
                    'vendor Name': banner.vendor.fullname,
                    'app image': banner.app_banner_url,
                    'show in app': banner.show_in_app,
                    "today's offer": banner.is_today_offer,
                    'web image': banner.web_banner_url,
                    full_data: banner
                }
            })
            this.banner_headings = [
                {
                    name: 'vendor Name',
                    icon: 'fa fa-user-o',
                },
                {
                    name: 'app image',
                    icon: 'fa fa-mobile',
                    type: 'IMAGE'
                },
                {
                    name: 'web image',
                    icon: 'fa fa-window-maximize',
                    type: 'IMAGE'
                },
                {
                    name: 'show in app',
                    icon: 'fa fa-eye',
                    type: 'SWITCH',
                    onclick: true,
                    onclick_emit: 'show_app'
                },
                {
                    name: "today's offer",
                    icon: 'fa fa-eye',
                    type: 'SWITCH',
                    onclick: true,
                    onclick_emit: 'today_offer'
                },
            ]
            this.banners = await Promise.all(mapped_banner)
        },
        async fetchBanners() {
            let query = `/fetch-waiting-banners-for-admin?page_number=${this.page_number ? this.page_number : 1}&per_page=${this.per_page}`
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.total_banners = response.data.banner_total
            const mapped_banner = response.data.banners.map(banner => {
                return {
                    'vendor Name': banner.vendor.fullname,
                    'app image': banner.app_banner_url,
                    // 'show in app': banner.show_in_app,
                    'web image': banner.web_banner_url,
                    full_data: banner
                }
            })
            this.banner_headings = [
                {
                    name: 'vendor Name',
                    icon: 'fa fa-user-o',
                },
                {
                    name: 'app image',
                    icon: 'fa fa-mobile',
                    type: 'IMAGE'
                },
                {
                    name: 'web image',
                    icon: 'fa fa-window-maximize',
                    type: 'IMAGE'
                },
                // {
                //     name: 'show in app',
                //     icon: 'fa fa-eye',
                //     type: 'SWITCH'
                // },
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
            this.banners = await Promise.all(mapped_banner)
        },
        async bannerToday(banner_id, stats) {
            const response = await this.$axios.post(`/assign-banner-to-today`, {
                banner_id,
                is_today_offer: stats
            })
            if (response.data.code == 401) {
                await this.logout()
            }
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
        },
        async banner_in_app(banner_id, stats) {
            const response = await this.$axios.post(`/assign-banner-to-app`, {
                banner_id,
                show_in_app: stats
            })
            if (response.data.code == 401) {
                await this.logout()
            }
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
        }
    }
}
</script>