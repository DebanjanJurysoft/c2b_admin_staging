<template>
    <div class="vendor-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="vendor-tabs">
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
                    <Pagination @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                    <Pagination @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approved_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                    <Pagination @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                </div>
            </div>
            <!-- table  -->
            <Table @callFunction="checkWhatIsCalled" v-if="selected_tab.id == 1" :headings="waiting_vendor_heading" :data_rows="waiting_vendor_list" />
            <Table v-if="selected_tab.id == 2" :headings="approved_vendors_heading" :data_rows="approved_vendor_list" />
            <Table v-if="selected_tab.id == 3" :headings="rejected_vendors_heading" :data_rows="rejected_vendor_list" />
            <!-- bottom pagination  -->
            <Pagination @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <Pagination @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approved_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <Pagination @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
        </div>
        <b-modal id="rejectVendorModal" hide-footer no-close-on-backdrop centered :title="modal_title" no>
            <b-form-textarea
                id="textarea"
                placeholder="Reason for rejection..."
                rows="3"
                v-model="rejection_reason"
                max-rows="6"
            ></b-form-textarea>
            <div class="d-flex text-center py-2">
                <span @click.prevent="rejectVendor" :class="rejection_reason ? 'logout-button' : 'disabled-button'">Reject</span>
            </div>
        </b-modal>
    </div>
</template>

<script>
import Loader from "./loader.vue"
import Pagination from "./pagination.vue"
import Table from "./table.vue"
export default {
    components: { Loader, Table, Pagination },
    props: ['searchText'],
    data() {
        return {
            loader: false,
            selected_tab: {
                id: 1,
                name: 'vendors_approval',
                text: 'vendors approval'
            },
            tabs: [
                {
                    id: 1,
                    name: 'vendors_approval',
                    text: 'vendors approval'
                },
                {
                    id: 2,
                    name: 'approved_vendors',
                    text: 'approved vendors'
                },
                {
                    id: 3,
                    name: 'vendors_disapproved',
                    text: 'disapproved vendors'
                },
            ],
            waiting_vendor_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
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
                    name: 'fssai no',
                    icon: null
                },
                {
                    name: 'gst no',
                    icon: null
                },
                {
                    name: 'phone',
                    icon: 'fa fa-phone'
                },
                {
                    name: 'alt phone',
                    icon: 'fa fa-phone'
                },
                {
                    name: 'identity proof',
                    icon: 'fa fa-question-circle'
                },
                {
                    name: 'identity proof image',
                    icon: 'fa fa-file-o'
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
            approved_vendors_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
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
                    name: 'fssai no',
                    icon: null
                },
                {
                    name: 'gst no',
                    icon: null
                },
                {
                    name: 'phone',
                    icon: 'fa fa-phone'
                },
                {
                    name: 'alt phone',
                    icon: 'fa fa-phone'
                },
                {
                    name: 'identity proof',
                    icon: 'fa fa-question-circle'
                },
                {
                    name: 'identity proof image',
                    icon: 'fa fa-file-o'
                },
            ],
            rejected_vendors_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket'
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket'
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
                    name: 'fssai no',
                    icon: null
                },
                {
                    name: 'gst no',
                    icon: null
                },
                {
                    name: 'phone',
                    icon: 'fa fa-phone'
                },
                {
                    name: 'alt phone',
                    icon: 'fa fa-phone'
                },
                {
                    name: 'identity proof',
                    icon: 'fa fa-question-circle'
                },
                {
                    name: 'identity proof image',
                    icon: 'fa fa-file-o'
                },
            ],
            waiting_vendor_list: [],
            approved_vendor_list: [],
            rejected_vendor_list: [],
            selected_vendor_id: null,
            modal_title: '',
            rejection_reason: null,
            selected_date: null,
            per_page: 7,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            page: 1,
            waiting_vendor_list_total: 0,
            approved_vendor_list_total: 0,
            rejected_vendor_list_total: 0,
            total_rows: 0,
            timer: null
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
        async mountedFunction() {
            await this.fetchVendorsWaitingForApproval()
            await this.fetchApprovedVendors()
            await this.fetchRejectedVendors()
        },
        async changePage(page_no) {
            this.page = page_no
            switch (this.selected_tab.id) {
                case 1:
                    await this.fetchVendorsWaitingForApproval()
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
        async rejectVendor() {
            const response = await this.$axios({
                method: 'post',
                url: '/reject-vendor', 
                data: {
                    vendor_id: this.selected_vendor_id,
                    reason: this.rejection_reason
                }
            })
            if (response.data.status == 'success') {
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'warning'
                })
            } else {
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            }
            this.closeModal('rejectVendorModal')
            await this.fetchVendorsWaitingForApproval()
            await this.mountedFunction()
        },
        async approveVendor() {
            const response = await this.$axios({
                method: 'post',
                url: '/approve-vendor', 
                data: {
                    vendor_id: this.selected_vendor_id,
                }
            })
            if (response.data.status == 'success') {
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'success'
                })
            } else {
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            }
            await this.fetchVendorsWaitingForApproval()
            await this.mountedFunction()
        },
        async checkWhatIsCalled(passedData) {
            try {
                const { emitMethod, id } = passedData
                switch (emitMethod) {
                    case "approve":
                        this.selected_vendor_id = id
                        this.vendor_status = true
                        await this.approveVendor()
                        break;
                    case "disapprove":
                        this.selected_vendor_id = id
                        this.vendor_status = false
                        const vendor = this.waiting_vendor_list.find(e => e.id == id)
                        console.log(vendor);
                        this.modal_title = `Rejecting of ${vendor['vendor name']}`
                        this.showModal('rejectVendorModal')
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
            this.page = 0
            this.loader = true
            switch (index) {
                case 0:
                    await this.fetchVendorsWaitingForApproval()
                    this.total_rows = this.waiting_vendor_list_total
                    break;
                case 1:
                    await this.fetchApprovedVendors()
                    this.total_rows = this.approved_vendor_list_total
                    break;
                case 2:
                    await this.fetchRejectedVendors()
                    this.total_rows = this.rejected_vendor_list_total
                    break;
            }
            this.selected_tab = this.tabs[index]
            this.loader = false
        },
        async fetchApprovedVendors() {
            try {
                let query = `/approved-vendor?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&vendor_name=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                this.approved_vendor_list = response.data.vendors.map(e => {
                    return {
                        'vendor name': e.fullname ? e.fullname : 'N/A',
                        'store name': e.stores ? e.stores.name : 'N/A',
                        'fssai no': e.stores ? e.stores.fssai_number : 'N/A',
                        'gst no': e.stores ? e.stores.gst_number : 'N/A',
                        'phone': e.personal_mobile ? e.personal_mobile : 'N/A',
                        'identity proof': e.identity_proof_name ? e.identity_proof_name : 'N/A',
                        'identity proof image': e.identity_proof_file_url ? e.identity_proof_file_url : 'N/A',
                        'alt phone': e.personal_alt_mobile ? e.personal_alt_mobile : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id
                    }
                })
                this.approved_vendor_list_total = response.data.total
                this.tabs.forEach(e => {
                    if (e.name == 'approved_vendors') {
                        e.text = `approved vendors (${response.data.total})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        async fetchRejectedVendors() {
            try {
                let query = `/rejected-vendor?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&vendor_name=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                this.rejected_vendor_list = response.data.vendors.map(e => {
                    return {
                        'vendor name': e.fullname ? e.fullname : 'N/A',
                        'store name': e.stores ? e.stores.name : 'N/A',
                        'fssai no': e.stores ? e.stores.fssai_number : 'N/A',
                        'gst no': e.stores ? e.stores.gst_number : 'N/A',
                        'phone': e.personal_mobile ? e.personal_mobile : 'N/A',
                        'identity proof': e.identity_proof_name ? e.identity_proof_name : 'N/A',
                        'identity proof image': e.identity_proof_file_url ? e.identity_proof_file_url : 'N/A',
                        'alt phone': e.personal_alt_mobile ? e.personal_alt_mobile : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id
                    }
                })
                this.rejected_vendor_list_total = response.data.total
                this.tabs.forEach(e => {
                    if (e.name == 'vendors_disapproved') {
                        e.text = `disapproved vendors (${response.data.total})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        async fetchVendorsWaitingForApproval() {
            try {
                let query = `/waiting-vendors-approval?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&vendor_name=${this.searchText}`
                }
                const response = await this.$axios.get(query)

                this.waiting_vendor_list = response.data.vendors.map(e => {
                    return {
                        'vendor name': e.fullname ? e.fullname : 'N/A',
                        'store name': e.stores ? e.stores.name : 'N/A',
                        'fssai no': e.stores ? e.stores.fssai_number : 'N/A',
                        'gst no': e.stores ? e.stores.gst_number : 'N/A',
                        'phone': e.personal_mobile ? e.personal_mobile : 'N/A',
                        'identity proof': e.identity_proof_name ? e.identity_proof_name : 'N/A',
                        'identity proof image': e.identity_proof_file_url ? e.identity_proof_file_url : 'N/A',
                        'alt phone': e.personal_alt_mobile ? e.personal_alt_mobile : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id
                    }
                })
                this.waiting_vendor_list_total = response.data.total
                this.tabs.forEach(e => {
                    if (e.name == 'vendors_approval') {
                        e.text = `vendors approval (${response.data.total})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        } 
    }
}
</script>