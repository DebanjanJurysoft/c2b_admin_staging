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
            <Table @callFunction="checkWhatIsCalled" :headings="waiting_vendor_heading" :data_rows="waiting_vendor_list" />
        </div>
    </div>
</template>

<script>
import Loader from "./loader.vue"
import Table from "./table.vue"
export default {
    components: { Loader, Table },
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
            waiting_vendor_list: []
        }
    },
    async mounted() { 
        this.loader = true
        await this.fetchVendorsWaitingForApproval()
        this.loader = false
    },
    methods: {
        async checkWhatIsCalled(passedData) {
            try {
                const { emitMethod, id } = passedData
                let data = {
                    vendor_ids: [id],
                }
                switch (emitMethod) {
                    case "approve":
                        data['approve'] = true
                        break;
                    case "disapprove":
                        data['approve'] = false
                        break;
                }
                const response = await this.$axios({
                    method: 'post',
                    url: '/approve-reject-vendors', 
                    data: data
                })
                if (response.data.status == 'success') {
                    this.$toast.show('Vendor is approved.', {
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
        },
        async fetchVendorsWaitingForApproval() {
            try {
                const response = await this.$axios.get('/waiting-vendors-approval')

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
                this.tabs.forEach(e => {
                    if (e.name == 'vendors_approval') {
                        e.text = `vendors approval (${this.waiting_vendor_list.length})`
                    }
                })
            } catch (error) {
                console.log(error);
            }
        } 
    }
}
</script>