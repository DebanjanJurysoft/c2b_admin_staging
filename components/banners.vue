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
                <div class="w-75 d-flex flex-row align-items-center" style="gap: 10px;">
                    <label class="mr-3">Rows:</label>
                    <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                    <button class="button" @click.preview="reloadPage"><i class="fa fa-refresh"></i></button>
                    <button class="button" @click.preview="openAdminBanner"><i class="fa fa-plus"><span class="text-heading" style="color: white; font-weight: 500; margin-left: 0px;">Admin Banner</span></i></button>
                    <button class="button" @click.preview="openVendorBanner"><i class="fa fa-plus"><span class="text-heading" style="color: white; font-weight: 500; margin-left: 0px;">Vendor Banner</span></i></button>
                </div>
                <div class="w-25">
                    <!-- top pagination  -->
                    <Pagination @changePage="changePage" :data_list="banners" :per_page="per_page" :total_rows="total_banners" :page="page_number"/>
                </div>
            </div>
            <Table @openSpecific="openSpecific" @callFunction="checkWhatIsCalled" :headings="banner_headings" :data_rows="banners" :file_name="export_file" :page="page_number" :rows="per_page" />
            <Pagination @changePage="changePage" :data_list="banners" :per_page="per_page" :total_rows="total_banners" :page="page_number"/>
            <b-modal
                id="vendorBanner" 
                hide-footer 
                hide-header 
                no-close-on-backdrop 
                centered 
            >
                <div class="d-flex flex-row align-items-center justify-content-between">
                    <span class="text-heading">Add Banner For Vendor</span>
                    <span class="text-danger cursor-pointer" @click.prevent="closeModal"><i class="fa fa-times mr-1"></i></span>
                </div>
                <div class="d-flex flex-column align-items-center w100 px-4 pt-4">
                    <div class="d-flex flex-row align-items-center w100 mb-3">
                        <div class="w30">
                            <label class="input-label">Vendor: </label>
                        </div>
                        <div class="w70">
                            <b-form-select 
                                type="text" 
                                style="
                                    width: 100% !important; 
                                    max-width: 100% !important; 
                                    min-width: 100% !important;
                                " 
                                placeholder="Select a vendor"
                                v-model="selected_vendor"
                                :options="vendor_list"
                            />
                        </div>
                    </div>
                    <div class="d-flex flex-column align-items-center w100 mb-3">
                        <div class="d-flex flex-row align-items-center w100">
                            <div class="w30">
                                <label class="input-label fontSize14">App Banner: </label>
                            </div>
                            <div class="w70">
                                <b-form-file placeholder="Drop or Choose" v-model="app_banner" accept="image/*, video/*"></b-form-file>
                            </div>
                        </div>
                        <span class="w100 text-heading text-danger fontSize12"><sup>*</sup>Image / Video (Max Size: 20MB)<sup>*</sup></span>
                    </div>
                    <div class="d-flex flex-column align-items-center w100">
                        <div class="d-flex flex-row align-items-center w100">
                            <div class="w30">
                            <label class="input-label fontSize14">Web Banner: </label>
                        </div>
                        <div class="w70">
                            <b-form-file placeholder="Drop or Choose" v-model="web_banner" accept="image/*, video/*"></b-form-file>
                        </div>
                        </div>
                        <span class="w100 text-heading text-danger fontSize12"><sup>*</sup>Image / Video (Max Size: 20MB)<sup>*</sup></span>
                    </div>
                    <div class="d-flex flex-row align-items-center w100 mb-3">
                        <div class="w30">
                            <label class="input-label fontSize14">Social Media Link: </label>
                        </div>
                        <div class="w70">
                            <b-form-input v-model="social_media_link" placeholder="Social Media Link"></b-form-input>
                        </div>
                    </div>
                    <div class="d-flex flex-row justify-content-center">
                        <button class="button" @click.prevent="addBannerVendor"><i class="fa fa-save mr-1"></i>Save</button>
                    </div>
                </div>
            </b-modal>
            <b-modal
                id="adminBanner" 
                hide-footer 
                hide-header 
                no-close-on-backdrop 
                centered 
            ><div class="d-flex flex-row align-items-center justify-content-between">
                    <span class="text-heading">Add Banner For Admin</span>
                    <span class="text-danger cursor-pointer" @click.prevent="closeModal"><i class="fa fa-times mr-1"></i></span>
                </div>
                <div class="d-flex flex-column align-items-center w100 px-4 pt-4">
                    <div class="d-flex flex-column align-items-center w100 mb-3">
                        <div class="d-flex flex-row align-items-center w100">
                            <div class="w30">
                                <label class="input-label fontSize14">App Banner: </label>
                            </div>
                            <div class="w70">
                                <b-form-file placeholder="Drop or Choose" v-model="app_banner" accept="image/*, video/*"></b-form-file>
                            </div>
                        </div>
                        <span class="w100 text-heading text-danger fontSize12"><sup>*</sup>Image / Video (Max Size: 20MB)<sup>*</sup></span>
                    </div>
                    <div class="d-flex flex-column align-items-center w100">
                        <div class="d-flex flex-row align-items-center w100">
                            <div class="w30">
                                <label class="input-label fontSize14">Web Banner: </label>
                            </div>
                            <div class="w70">
                                <b-form-file placeholder="Drop or Choose" v-model="web_banner" accept="image/*, video/*"></b-form-file>
                            </div>
                        </div>
                        <span class="w100 text-heading text-danger fontSize12"><sup>*</sup>Image / Video (Max Size: 20MB)<sup>*</sup></span>
                    </div>
                    <div class="d-flex flex-row align-items-center w100 mb-3">
                        <div class="w30">
                            <label class="input-label fontSize14">Social Media Link: </label>
                        </div>
                        <div class="w70">
                            <b-form-input v-model="social_media_link" placeholder="Social Media Link"></b-form-input>
                        </div>
                    </div>
                    <div class="d-flex flex-row justify-content-center">
                        <button class="button" @click.prevent="addBannerAdmin"><i class="fa fa-save mr-1"></i>Save</button>
                    </div>
                </div>
            </b-modal>
            <b-modal
                id="BannerView" 
                hide-footer 
                lazy
                header-bg-variant="dark"
                header-text-variant="light"
                :title="selected_banner_title" 
            >
                <div class="w100">
                    <img class="w100" :src="selected_banners" alt="Banner">
                </div>
            </b-modal>
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
            total_banners: 0,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            per_page: 5,
            page_number: 1,
            vendor_list: [],
            social_media_link: null,
            web_banner: null,
            app_banner: null,
            selected_vendor: null,
            selected_banners: null,
            selected_banner_title: null,
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchBannerCount()
        await this.changePage(1)

        this.loader = false
    },
    watch: {
        per_page() {
            this.changePage(this.page)
        },
    },
    methods: {
        async addBannerVendor() { 
            try {
                this.loader = true
                const formData = new FormData()
                formData.append('web_image', this.web_banner)
                formData.append('app_image', this.app_banner)
                formData.append('vendor_id', this.selected_vendor)
                if (this.social_media_link) {
                    formData.append('social_link', this.social_media_link)
                }
                formData.append('active', true)
                const path = '/add-banner'
                const response = await this.$axios.post(path, formData)
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.closeModal()
                this.changeTab(1)
                this.loader = false
            } catch (error) {
                console.log(error);
                this.$toast.show(error.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            }
        },
        async addBannerAdmin() { 
            try {
                this.loader = true
                const formData = new FormData()
                formData.append('web_image', this.web_banner)
                formData.append('app_image', this.app_banner)
                if (this.social_media_link) {
                    formData.append('social_link', this.social_media_link)
                }
                formData.append('active', true)
                const path = '/add-banner'
                const response = await this.$axios.post(path, formData)
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.closeModal()
                this.changeTab(1)
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        },
        closeModal() {
            this.$bvModal.hide('adminBanner')
            this.$bvModal.hide('vendorBanner')
            this.selected_vendor = null
            this.web_banner = null
            this.app_banner = null
            this.social_media_link = null
        },
        async openAdminBanner() {
            try {
                this.$bvModal.show('adminBanner')
            } catch (error) {
                console.log(error);
            }
        },
        async openVendorBanner() {
            try {
                await this.fetchApprovedVendors()
                this.$bvModal.show('vendorBanner')
            } catch (error) {
                console.log(error);
            }
        },
        async fetchApprovedVendors() {
            try {
                let query = `/approved-vendor`
                if (this.searchText && this.searchText != '') {
                    query = query + `&vendor_name=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.vendor_list = response.data.vendors.map(e => {
                    return {
                        value: e.id,
                        text: `${e.fullname} (${e.store.name})`
                    }
                })
                this.vendor_list.unshift({
                    value: null,
                    text: 'Select a vendor'
                });
            } catch (error) {
                console.log(error);
            }
        },
        async reloadPage() { 
            this.loader = true
            await this.changePage(1)
            this.$emit('reloadDashboard')
            this.loader = false
        },
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
                    case "delete":
                        await this.deleteWithPopup('/delete-banner', 'banner_id', data.full_data.id)
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
                            await this.fetchBannerCount()
                            await this.changePage(this.page_number)  
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
            this.changePage(1)
        },
        openSpecific(data) {
            if (data.type == 'show_app') {
                this.banner_in_app(data.data.full_data.id, data.data['show in app'])
            }
            if (data.type == 'today_offer') {
                this.bannerToday(data.data.full_data.id, data.data["today's offer"])
            }
            if (data.type == 'view_app_banner') { 
                this.selected_banners = this.banners[data.row_index]['app image']
                this.selected_banner_title = 'Showing Application Banner'
                this.$bvModal.show('BannerView')
            }
            if (data.type == 'view_web_banner') {
                this.selected_banners = this.banners[data.row_index]['web image']
                this.selected_banner_title = 'Showing Website Banner'
                this.$bvModal.show('BannerView')
            }
        },
        async fetchApprovedBanners() {
            let query = `/fetch-approved-banners-for-admin?page_number=${this.page_number ? this.page_number : 1}&per_page=${this.per_page}`
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
            }
            this.total_banners = response.data.banner_total
            const videoExtensions = ['mp4', 'webm', 'mkv', 'avi', 'mov', 'wmv'];
            const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
            const mapped_banner = response.data.banners.map(banner => {
                return {
                    'vendor Name': banner.vendor ? banner.vendor.fullname : 'ADMIN',
                    'app image': banner.app_banner_url ? imageExtensions.includes(banner.app_banner_url.split('.').pop()) ? banner.app_banner_url : 'N/A' : 'N/A',
                    'app video': banner.app_banner_url ? videoExtensions.includes(banner.app_banner_url.split('.').pop()) ? banner.app_banner_url : 'N/A' : 'N/A',
                    'show in app': banner.show_in_app,
                    "social media link": banner.social_link ? banner.social_link : 'N/A',
                    "today's offer": banner.is_today_offer,
                    'web image': banner.web_banner_url ?  imageExtensions.includes(banner.web_banner_url.split('.').pop()) ? banner.web_banner_url : 'N/A' : 'N/A',
                    'web video': banner.web_banner_url ? videoExtensions.includes(banner.web_banner_url.split('.').pop()) ? banner.web_banner_url : 'N/A' : 'N/A',
                    full_data: banner
                }
            })
            this.banner_headings = [
                {
                    name: 'vendor Name',
                    icon: 'fa fa-user-o',
                },
                {
                    name: 'social media link',
                    icon: 'fa fa-user-o',
                    type: 'FILE'
                },
                {
                    name: 'app image',
                    icon: 'fa fa-mobile',
                    type: 'IMAGE',
                    onclick: true,
                    onclick_emit: 'view_app_banner'
                },
                {
                    name: 'web image',
                    icon: 'fa fa-window-maximize',
                    type: 'IMAGE',
                    onclick: true,
                    onclick_emit: 'view_web_banner'
                },
                {
                    name: 'app video',
                    icon: 'fa fa-mobile',
                    type: 'VIDEO',
                },
                {
                    name: 'web video',
                    icon: 'fa fa-window-maximize',
                    type: 'VIDEO',
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
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            text: 'Delete',
                            icon: 'fa fa-trash',
                            color: 'red',
                            border: 'none',
                            emit_name: 'delete'
                        },
                    ]
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
                    'vendor Name': banner.vendor ? banner.vendor.fullname : 'ADMIN',
                    'app image': imageExtensions.includes(banner.app_banner_url.split('.').pop()) ? banner.app_banner_url : 'N/A',
                    'app video': banner.app_banner_url ? videoExtensions.includes(banner.app_banner_url.split('.').pop()) ? banner.app_banner_url : 'N/A' : 'N/A',
                    'show in app': banner.show_in_app,
                    "social media link": banner.social_link ? banner.social_link : 'N/A',
                    "today's offer": banner.is_today_offer,
                    'web image': imageExtensions.includes(banner.web_banner_url.split('.').pop()) ? banner.web_banner_url : 'N/A',
                    'web video': banner.web_banner_url ? videoExtensions.includes(banner.web_banner_url.split('.').pop()) ? banner.web_banner_url : 'N/A' : 'N/A',
                    full_data: banner
                }
            })
            this.banner_headings = [
            {
                    name: 'vendor Name',
                    icon: 'fa fa-user-o',
                },
                {
                    name: 'social media link',
                    icon: 'fa fa-user-o',
                    type: 'FILE'
                },
                {
                    name: 'app image',
                    icon: 'fa fa-mobile',
                    type: 'IMAGE',
                    onclick: true,
                    onclick_emit: 'view_app_banner'
                },
                {
                    name: 'web image',
                    icon: 'fa fa-window-maximize',
                    type: 'IMAGE',
                    onclick: true,
                    onclick_emit: 'view_web_banner'
                },
                {
                    name: 'app video',
                    icon: 'fa fa-mobile',
                    type: 'VIDEO',
                },
                {
                    name: 'web video',
                    icon: 'fa fa-window-maximize',
                    type: 'VIDEO',
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
                        {
                            text: 'Delete',
                            icon: 'fa fa-trash',
                            color: 'red',
                            border: 'none',
                            emit_name: 'delete'
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
        }, 
    }
}
</script>

