<template>
    <div class="vendor-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="vendor-tabs">
            <div @click.prevent="changeTab(index)" v-for="(tab, index) in tabs" :key="index" :class="selected_tab.id == tab.id ? 'tab-items-active' : 'tab-items'">
                <span>{{ tab.text }}</span>
            </div>
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row w-100">
                <div class="d-flex flex-row mb-3 flex-fill align-items-center w-100">
                    <div class="flex-fill">
                        <div class="d-flex flex-row align-items-center" style="gap: 10px">
                            <label class="mr-3">Rows:</label>
                            <b-form-select style="width: 100px;" v-model="per_page" :options="per_page_options"></b-form-select>
                            <button
                                v-b-tooltip.hover
                                title="Reload"
                                class="button float-right ml-3" 
                                @click.prevent="reloadPage"><i class="fa fa-refresh"></i></button>
                        </div>
                    </div>
                    <div class="flex-fill d-flex flex-row-reverse" style="width: max-content !important;">
                        <!-- top pagination  -->
                        <button class="button float-right ml-3" @click.prevent="OpenVendor_adding_modal"><i class="fa fa-plus mr-2"></i>Add</button>
                    </div>
                </div>
                <div class="d-flex flex-row flex-fill ml-3" style="width: max-content !important;">
                    <div>
                        <Pagination class="float-right" @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                        <Pagination class="float-right" @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approved_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                        <Pagination class="float-right" @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
                    </div>
                </div>
            </div>
            <!-- table  -->
            <Table @openDetails="openDetails" @callFunction="checkWhatIsCalled" v-if="selected_tab.id == 1" :headings="waiting_vendor_heading" :data_rows="waiting_vendor_list" :file_name="'waiting_vendor_list.csv'" :page="page" :rows="per_page"/>
            <Table @openSpecific="openSpecific" @openDetails="openDetails" @callFunction="checkWhatIsCalled" v-if="selected_tab.id == 2" :headings="approved_vendors_heading" :data_rows="approved_vendor_list" :file_name="'approved_vendor_list.csv'" :page="page" :rows="per_page"/>
            <Table @openDetails="openDetails" @callFunction="checkWhatIsCalled" v-if="selected_tab.id == 3" :headings="rejected_vendors_heading" :data_rows="rejected_vendor_list" :file_name="'rejected_vendor_list.csv'" :page="page" :rows="per_page"/>
            <!-- bottom pagination  -->
            <Pagination @changePage="changePage" v-if="selected_tab.id == 1" :data_list="waiting_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <Pagination @changePage="changePage" v-if="selected_tab.id == 2" :data_list="approved_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
            <Pagination @changePage="changePage" v-if="selected_tab.id == 3" :data_list="rejected_vendor_list" :per_page="per_page" :total_rows="total_rows" :selected_tab="selected_tab" :page="page"/>
        </div>
        <b-modal id="addVendor" size="lg" style="height: max-content !important;" hide-footer no-close-on-backdrop centered :title="modal_title">
            <Vendor_form style="height: max-content !important;" :type="type" :vendor_data_for_edit="selected_vendor_for_edit"  @closeModal="closeAddVendorModal" />
        </b-modal>
        <b-modal id="rejectVendorModal" hide-footer no-close-on-backdrop centered :title="modal_title">
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
        <b-modal id="showVendorDetailsModal" centered :hide-footer="selected_tab.id != 1" scrollable :footer-class="selected_tab.id != 1 ? '' : 'justify-content-center'" >
            <template #modal-header>
                <!-- Emulate built in modal header close button action -->
                <h5>{{ `SL No: ${formatSerial(view_vendor_data ? view_vendor_data.id : 0)}` }}</h5>
                <div class="date_container">
                    Date : {{ view_vendor_data.date }}
                </div>
            </template>
            <b-container fluid style="height: 450px; overflow-y: scroll !important;" v-if="view_vendor_data" class="d-flex flex-column">
                <div class="w-100 d-flex flex-row justify-content-center">
                    <span style="text-transform: capitalize;" class="text-center h3">Vendor Details</span>
                </div>
                <template v-for="(item, index) in Object.keys(view_vendor_data.full_data)">
                    <template v-if="view_vendor_data?.full_data[item] && typeof view_vendor_data.full_data[item] === 'object'">
                        <div class="w-100 d-flex flex-row justify-content-center">
                            <span style="text-transform: capitalize;" class="text-center h3">{{ item }}</span>
                        </div>
                        <template v-for="(tempitem, tempindex) in Object.keys(view_vendor_data?.full_data[item])">
                            <template v-if="view_vendor_data?.full_data[item][tempitem] && testJSON(view_vendor_data?.full_data[item][tempitem])" >
                                <!-- <div class="w-100 d-flex flex-row">
                                    <span>{{ tempitem }}</span>
                                </div>
                                <template v-for="(innertempitem, innertempindex) in JSON.parse(view_vendor_data?.full_data[item][tempitem])">
                                    <div class="d-flex flex-row" style="height: fit-content;" :key="'inner'+innertempindex">
                                        <span style="width: 45% !important;">type</span>
                                        <span style="width: 10% !important;">:</span>
                                        <span style="width: 45% !important; text-transform: capitalize;">{{ innertempitem.type }}</span>
                                    </div>
                                </template> -->
                            </template>
                            <div v-else class="d-flex flex-row" style="height: fit-content;" :key="'temp'+tempindex">
                                <span style="width: 45% !important;">{{tempitem}}</span>
                                <span style="width: 10% !important;">:</span>
                                <span v-if="view_vendor_data?.full_data[item][tempitem] && view_vendor_data?.full_data[item][tempitem] != '' && !isValidHttpUrl(view_vendor_data?.full_data[item][tempitem])" style="width: 45% !important; text-transform: capitalize;">{{ view_vendor_data?.full_data[item][tempitem] }}</span>
                                <a v-else-if="view_vendor_data?.full_data[item][tempitem] != ''" target="_blank" :href="view_vendor_data?.full_data[item][tempitem]">{{tempitem.replaceAll('_', ' ')}}</a>
                                <span v-else>N/A</span>
                            </div>
                        </template>
                    </template>
                    <div class="d-flex flex-row" style="height: fit-content;" :key="'main'+index" v-if="typeof view_vendor_data.full_data[item] !== 'object'" >
                        <span style="width: 45% !important;">{{item}}</span>
                        <span style="width: 10% !important;">:</span>
                        <span v-if="view_vendor_data?.full_data[item] && view_vendor_data?.full_data[item] != '' && !isValidHttpUrl(view_vendor_data?.full_data[item])" style="width: 45% !important; text-transform: capitalize;">{{ view_vendor_data?.full_data[item] }}</span>
                        <a v-else-if="view_vendor_data?.full_data[item] != ''" target="_blank" :href="view_vendor_data?.full_data[item]">{{item.replaceAll('_', ' ')}}</a>
                        <span v-else>N/A</span>
                    </div>
                </template>
            </b-container>
            <!-- <b-container fluid style="height: 450px;" v-if="view_vendor_data" class="d-flex flex-column">
                <div class="row">
                    <span class="col-5">Vendor Name</span>
                    <span class="col-1">:</span>
                    <span class="col-6" style="text-transform: capitalize;">{{ view_vendor_data['vendor name'] }}</span>
                </div>
                <div class="row">
                    <span class="col-5">Store Name</span>
                    <span class="col-1">:</span>
                    <span class="col-6" style="text-transform: capitalize;">{{ view_vendor_data['store name'] }}</span>
                </div>
                <div class="row">
                    <span class="col-5">FSSAI No</span>
                    <span class="col-1">:</span>
                    <span class="col-6" style="text-transform: uppercase;">{{ view_vendor_data['fssai no'] }}</span>
                </div>
                <div class="row">
                    <span class="col-5">GST No</span>
                    <span class="col-1">:</span>
                    <span class="col-6" style="text-transform: uppercase;">{{ view_vendor_data['gst no'] }}</span>
                </div>
                <div class="row">
                    <span class="col-5">Store Address</span>
                    <span class="col-1">:</span>
                    <span class="col-6" v-b-tooltip.hover :title="view_vendor_data.full_data.store ? `${view_vendor_data.full_data.store.add1}, ${view_vendor_data.full_data.store.add2 ? view_vendor_data.full_data.store.add2+',' : ''} ${view_vendor_data.full_data.store.city}, ${view_vendor_data.full_data.store.area}, ${view_vendor_data.full_data.store.landmark}, ${view_vendor_data.full_data.store.state}, ${view_vendor_data.full_data.store.pincode}` : 'N/A'" style="text-overflow: ellipsis; overflow: hidden; white-space: nowrap; text-transform: capitalize;">{{ view_vendor_data.full_data.store ? `${view_vendor_data.full_data.store.add1}, ${view_vendor_data.full_data.store.add2+',' || ''} ${view_vendor_data.full_data.store.city}, ${view_vendor_data.full_data.store.area}, ${view_vendor_data.full_data.store.landmark}, ${view_vendor_data.full_data.store.state}, ${view_vendor_data.full_data.store.pincode}` : 'N/A' }}</span>
                </div>
                <div class="row">
                    <span class="col-5">Phone Number</span>
                    <span class="col-1">:</span>
                    <span class="col-6">{{ view_vendor_data.phone }}</span>
                </div>
                <div class="row">
                    <span class="col-5">Alt Phone Number</span>
                    <span class="col-1">:</span>
                    <span class="col-6">{{ view_vendor_data['alt phone'] }}</span>
                </div>
                <div class="row">
                    <span class="col-5">ID Proof</span>
                    <span class="col-1">:</span>
                    <span class="col-6">{{ view_vendor_data['identity proof'] }}</span>
                </div>
                <div class="row">
                    <span class="col-5">Date</span>
                    <span class="col-1">:</span>
                    <span class="col-6">{{ view_vendor_data.date }}</span>
                </div>
                <div class="d-flex justify-content-center" v-if="view_vendor_data['identity proof image'] != 'N/A'">
                    <img width="270" :src="view_vendor_data['identity proof image']" :alt="view_vendor_data['identity proof']">
                </div>
            </b-container> -->
            <template #modal-footer>
                <div class="d-flex" style="gap: 10px">
                    <span class="reject-button" @click.prevent="callCheck({
                        emitMethod: 'disapprove',
                        data: view_vendor_data
                    })">Reject</span>
                    <span class="approve-button" @click.prevent="callCheck({
                        emitMethod: 'approve',
                        data: view_vendor_data
                    })">Approve</span>
                </div>
            </template>
        </b-modal>
    </div>
</template>

<script>
import Loader from "./loader.vue"
import Pagination from "./pagination.vue"
import Table from "./table.vue"
import Vendor_form from "./vendor_form.vue"
export default {
    components: { Loader, Table, Pagination, Vendor_form },
    props: ['searchText'],
    data() {
        return {
            type: 'ADD',
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
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'vendor fullname',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket',
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
                    icon: 'fa fa-file-o',
                    type: 'IMAGE'
                },
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            icon: 'fa fa-pencil-square-o',
                            emit_name: 'edit',
                            text: 'Edit',
                            color: '#F79009',
                            border: 'none',
                        },
                        {
                            icon: 'fa fa-ban',
                            emit_name: 'disapprove',
                            text: 'Disapprove',
                            color: 'red',
                            border: 'none',
                        },
                        {
                            emit_name: 'approve',
                            icon: 'fa fa-check',
                            text: 'Approve',
                            color: 'green',
                            border: 'none',
                        },
                    ]
                },
            ],
            approved_vendors_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'vendor fullname',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'Active / Inactive',
                    icon: 'fa fa-power-off',
                    type: 'SWITCH',
                    onclick: true,
                    onclick_emit: 'activeInactiveVendor'
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
                    icon: 'fa fa-file-o',
                    type: 'IMAGE'
                },
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            text: 'Edit',
                            icon: 'fa fa-pencil-square-o',
                            color: '#F79009',
                            border: 'none',
                            emit_name: 'edit'
                        },
                        {
                            icon: 'fa fa-ban',
                            emit_name: 'disapprove',
                            text: 'Disapprove',
                            color: 'red',
                            border: 'none',
                        },
                    ]
                },
            ],
            rejected_vendors_heading: [
                {
                    name: 'vendor name',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'vendor fullname',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'store name',
                    icon: 'fa fa-shopping-basket',
                    onclick: true
                },
                {
                    name: 'reason',
                    icon: 'fa fa-question'
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
                    icon: 'fa fa-file-o',
                    type: 'IMAGE'
                },
                {
                    name: 'action',
                    icon: 'fa fa-cog',
                    buttons: [
                        {
                            text: 'Move To Pending For Approval',
                            icon: 'fa fa-arrows-alt',
                            color: 'red',
                            border: 'none',
                            emit_name: 'move_to_approval'
                        },
                    ]
                },
            ],
            waiting_vendor_list: [],
            approved_vendor_list: [],
            rejected_vendor_list: [],
            selected_vendor_id: null,
            modal_title: '',
            rejection_reason: null,
            selected_date: null,
            per_page: 5,
            per_page_options: Array.from(Array(15).keys()).map(e => e + 1),
            page: 1,
            waiting_vendor_list_total: 0,
            approved_vendor_list_total: 0,
            rejected_vendor_list_total: 0,
            total_rows: 0,
            timer: null,
            view_vendor_data: null,
            selected_vendor_for_edit: {},
            intervalTimeOut: null,
            localStorageServer: null
        }
    },
    async mounted() { 
        this.loader = true
        const data = await this.checkTab()
        if (data) {
            this.selected_tab = this.tabs[0]
            await this.reloadPage()
        }
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
        async checkTab() {
            this.localStorageServer = localStorage.getItem('navData')
            if (typeof this.localStorageServer === 'string') {
                this.localStorageServer = JSON.parse(this.localStorageServer)
                if (this.localStorageServer.inner_nav) {
                    this.changeTab(this.tabs.indexOf(this.tabs.find(e => e.id == this.localStorageServer.inner_nav.id)))
                }
            }
            return true
        },
        isValidHttpUrl(string) {
            let url;
            
            try {
                url = new URL(string);
            } catch (_) {
                return false;  
            }

            return url.protocol === "http:" || url.protocol === "https:";
        },
        async openSpecific(data) {
            try {
                if (data.type == 'activeInactiveVendor') {
                    const path = '/active-inactive-vendor'
                    const response = await this.$axios.post(path, {
                        vendor_id: data.data.id,
                        activeInactive: data.data["Active / Inactive"]
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
                    await this.reloadPage()
                }
            } catch (error) {
                console.log(error);
            }
        },
        testJSON(text) {
            if (typeof text !== "string") {
                return false;
            }
            try {
                JSON.parse(text);
                return true;
            } catch (error) {
                return false;
            }
        },
        async callCheck(data) { 
            await this.checkWhatIsCalled(data)
            this.closeModal('showVendorDetailsModal')
        },
        async closeAddVendorModal() {
            this.closeModal('addVendor')
            this.reloadPage()
        },
        async reloadPage() {
            this.loader = true
            await this.mountedFunction()
            await this.changeTab(this.tabs.indexOf(this.tabs.find( e => e.id == this.selected_tab.id)))
            this.$emit('reloadDashboard')
            this.loader = false
        },
        formatSerial(number) {
            if (number < 10) {
                return `000${number}`;
            } else if (number < 100) {
                return `00${number}`;
            } else if (number < 1000) {
                return `0${number}`;
            } else {
                return `${number}`;
            }
        },
        async openDetails(data) { 
            const index = parseInt(data)
            switch (this.selected_tab.id) {
                case 1:
                    this.selected_vendor_for_edit = this.waiting_vendor_list[index].full_data;
                    this.type = 'EDIT'
                    this.showModal('addVendor')
                    break;
                case 2:
                    this.selected_vendor_for_edit = this.approved_vendor_list[index].full_data;
                    this.type = 'EDIT'
                    this.showModal('addVendor')
                    break;
                case 3:
                    this.view_vendor_data = this.rejected_vendor_list[index]
                    this.showModal('showVendorDetailsModal')
                    break;
            }
        },
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
            if (response.data.code == 401) {
                await this.logout()
            }
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
            this.rejection_reason = null
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
            if (response.data.code == 401) {
                await this.logout()
            }
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
                const { emitMethod, data } = passedData
                switch (emitMethod) {
                    case 'edit': 
                        this.selected_vendor_for_edit = data.full_data
                        this.type = 'EDIT'
                        this.showModal('addVendor')
                        break
                    case "approve":
                        this.selected_vendor_id = data.id
                        this.vendor_status = true
                        await this.approveVendor()
                        break;
                    case "disapprove":
                        this.selected_vendor_id = data.id
                        this.vendor_status = false
                        const vendor = this.selected_tab.id == 1 ? this.waiting_vendor_list.find(e => e.id == data.id) : this.selected_tab.id == 2 ? this.approved_vendor_list.find(e => e.id == data.id) : null
                        this.modal_title = `Rejecting of ${vendor['vendor name']}`
                        this.showModal('rejectVendorModal')
                        break;
                    case "move_to_approval":
                        const path = '/move-disapproved-vendor-to-waiting'
                        const response = await this.$axios.post(path, {
                            vendor_id: data.id
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
                        await this.reloadPage()
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
            if (localStorage.getItem('navData')) {
                localStorage.removeItem('navData')
            }
            this.loader = true
            this.selected_tab = this.tabs[index]
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
            this.loader = false
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        async fetchApprovedVendors() {
            try {
                let query = `/approved-vendor?page=${this.page ? this.page : 1}&per_page=${this.per_page}`
                if (this.searchText && this.searchText != '') {
                    query = query + `&vendor_name=${this.searchText}`
                }
                const response = await this.$axios.get(query)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.approved_vendor_list = response.data.vendors.map(e => {
                    return {
                        'vendor name': e.fullname ? e.fullname : 'N/A',
                        'vendor fullname': e.first_name && e.last_name ? `${e.first_name} ${e.last_name}` : 'N/A',
                        'store name': e.store ? e.store.name : 'N/A',
                        'fssai no': e.store ? e.store.fssai_number : 'N/A',
                        'gst no': e.store ? e.store.gst_number : 'N/A',
                        'phone': e.personal_mobile ? e.personal_mobile : 'N/A',
                        'identity proof': e.identity_proof_name ? e.identity_proof_name : 'N/A',
                        'identity proof image': e.identity_proof_file_url ? e.identity_proof_file_url : 'N/A',
                        'Active / Inactive': e.is_active != null ? Boolean(e.is_active) : 'N/A',
                        'alt phone': e.personal_alt_mobile ? e.personal_alt_mobile : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id,
                        full_data: e
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
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.rejected_vendor_list = response.data.vendors.map(e => {
                    return {
                        'vendor name': e.fullname ? e.fullname : 'N/A',
                        'vendor fullname': e.first_name && e.last_name ? `${e.first_name} ${e.last_name}` : 'N/A',
                        'store name': e.store ? e.store.name : 'N/A',
                        'reason': e.rejected_vendor.reason ? e.rejected_vendor.reason : 'N/A',
                        'fssai no': e.store ? e.store.fssai_number : 'N/A',
                        'gst no': e.store ? e.store.gst_number : 'N/A',
                        'phone': e.personal_mobile ? e.personal_mobile : 'N/A',
                        'identity proof': e.identity_proof_name ? e.identity_proof_name : 'N/A',
                        'identity proof image': e.identity_proof_file_url ? e.identity_proof_file_url : 'N/A',
                        'alt phone': e.personal_alt_mobile ? e.personal_alt_mobile : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id,
                        full_data: e
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
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.waiting_vendor_list = response.data.vendors.map(e => {
                    return {
                        'vendor name': e.fullname ? e.fullname : 'N/A',
                        'vendor fullname': e.first_name && e.last_name ? `${e.first_name} ${e.last_name}` : 'N/A',
                        'store name': e.store ? e.store.name : 'N/A',
                        'fssai no': e.store ? e.store.fssai_number : 'N/A',
                        'gst no': e.store ? e.store.gst_number : 'N/A',
                        'phone': e.personal_mobile ? e.personal_mobile : 'N/A',
                        'identity proof': e.identity_proof_name ? e.identity_proof_name : 'N/A',
                        'identity proof image': e.identity_proof_file_url ? e.identity_proof_file_url : 'N/A',
                        'alt phone': e.personal_alt_mobile ? e.personal_alt_mobile : 'N/A',
                        'date': e.createdAt ? new Date(e.createdAt).toLocaleDateString() : 'N/A',
                        'time': e.createdAt ? new Date(e.createdAt).toLocaleTimeString() : 'N/A',
                        id: e.id,
                        full_data: e
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
        },
        async OpenVendor_adding_modal() {
            this.selected_vendor_for_edit = {}
            this.modal_title = 'Add New Vendor'
            this.type = 'ADD'
            this.showModal('addVendor')
        }
    }
}
</script>