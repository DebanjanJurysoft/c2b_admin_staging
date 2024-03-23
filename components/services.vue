<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-else class="pl-3 pr-3">
            <div class="d-flex">
                <div class="tab-items" @click.prevent="changeTab(tab)" :class="selectedTab.id == tab.id ? 'tab-items-active' : ''" v-for="(tab, index) in tabs" :key="index">
                    <span>{{ tab.text }}</span>
                </div>
            </div>
            <template v-if="selectedTab.id == 1">
                <div class="d-flex flex-row-reverse py-3 px-3 gap10">
                    <button class="button" @click.prevent="showHideModal(true, 'services')"><i class="fa fa-plus mr-2"></i>Add</button>
                    <button class="button" @click.prevent="showBulkUploadOption"><i class="fa fa-list mr-2"></i> Bulk Upload</button>
                    <button class="button" @click.prevent="downloadSample"><i class="fa fa-download mr-2"></i> Download CSV For Bulk Upload</button>
                </div>
                <table class="table table-hover" v-if="!servicesList.length">
                    <tr class="text-center">
                        No Record Found
                    </tr>
                </table>
                <table class="table table-hover" v-else>
                    <thead>
                        <th style="text-transform: uppercase;">SL No.</th>
                        <th style="text-transform: uppercase;">Service Name</th>
                        <th style="text-transform: uppercase;">Service Image</th>
                        <th style="text-transform: uppercase;">Price Per Day</th>
                        <th style="text-transform: uppercase;">Price Per Month</th>
                        <th style="text-transform: uppercase; text-align: center;">Action</th>
                    </thead>
                    <tbody>
                        <tr v-for="(service, service_index) in servicesList">
                            <td>{{ service_index + 1 }}</td>
                            <td>{{ service.name }}</td>
                            <td>
                                <img :src="service.image" alt="Service Image" height="38px">
                            </td>
                            <td>{{ service.per_day_price }}</td>
                            <td>{{ service.per_month_price }}</td>
                            <td class="d-flex justify-content-center lign-items-center gap10">
                                <button class="button" @click.prevent="openEdit(service)"><i class="fa fa-pencil"></i></button>
                                <button class="button" @click.prevent="removeService(service.id)"><i class="fa fa-trash"></i></button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </template>
            <template v-else-if="selectedTab.id == 2">
                <div class="d-flex flex-column gap10 py-3 px-3">
                    <div class="d-flex flex-row-reverse gap10 align-items-center">
                        <button class="button" @click.prevent="fetchForToday">Today</button>
                        <b-form-select style="width: max-content;" @change="fetchAllServicesRequestedByCustomers" v-model="selected_customer" :options="customers"></b-form-select>
                        <b-form-select style="width: max-content;" @change="fetchAllServicesRequestedByCustomers" v-model="selected_service" :options="service_list"></b-form-select>
                    </div>
                    <div>
                        <table class="table table-hover" v-if="requested_services_list.length == 0">
                            <tr class="text-center">
                                No Record Found
                            </tr>
                        </table>
                        <table class="main-table" v-else>
                            <thead>
                                <th class="heading">SL No.</th>
                                <th class="heading">Service Name</th>
                                <th class="heading">Customer Name</th>
                                <th class="heading">Paid Amount</th>
                                <th class="heading">Paid Date</th>
                                <th class="heading">Valid Till Date</th>
                            </thead>
                            <tbody>
                                <tr class="table-rows" v-for="(service_request, req_index) in requested_services_list">
                                    <td>{{ req_index + 1 }}</td>
                                    <td>{{ service_request.service.name }}</td>
                                    <td>{{ service_request.customer.fullname }}</td>
                                    <td>{{ service_request.payment_amount }}</td>
                                    <td>{{ new Date(service_request.createdAt).toLocaleDateString() }}</td>
                                    <td>{{ new Date(service_request.end_date).toLocaleDateString() }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </template>
        </div>
        <b-modal
            size="xl"
            id="bulkUploadServices" 
            hide-footer 
            hide-header 
            no-close-on-backdrop 
            centered 
        >
            <UploadServicesInBulkComponent @setData="setData"/>
            <div class="d-flex gap10 justify-content-center mt-3">
                <button class="button" @click.prevent="hideBulkUploadOption"><i class="fa fa-ban mr-2"></i>CLOSE</button>
                <button class="button" @click.prevent="saveData"><i class="fa fa-save mr-2"></i>SAVE</button>
            </div>
        </b-modal>
        <b-modal
            id="services" 
            hide-footer 
            hide-header 
            no-close-on-backdrop 
            centered 
        >
        <div>
            <div class="d-flex justify-content-between align-items-center">
                <span>{{ singleData.id ? 'Update Service' : 'Create New Service' }}</span>
                <button class="button" @click.prevent="showHideModal(false, 'services')"><i class="fa fa-times"></i></button>
            </div>
            <div class="d-flex flex-column py-3">
                <div class="d-flex flex-column">
                    <span class="input-label">Service Name:</span>
                    <b-form-input v-model="singleData.service_name" placeholder="Service Name"></b-form-input>
                </div>
                <div class="d-flex flex-column">
                    <span class="input-label">Per Month Price:</span>
                    <b-form-input v-model="singleData.per_month_price" placeholder="Per Month Price"></b-form-input>
                </div>
                <div class="d-flex flex-column">
                    <span class="input-label">Per Day Price:</span>
                    <b-form-input v-model="singleData.per_day_price" placeholder="Per Day Price"></b-form-input>
                </div>
                <div class="d-flex flex-column">
                    <span class="input-label">Service Image:</span>
                    <b-form-file @input="handleFileInput($event)" v-model="singleData.file2" class="mt-3" plain></b-form-file>
                    <div v-if="singleData.image" class="d-flex flex-column align-items-center">
                        <img :src="singleData.image" alt="Image" width="100" height="100">
                        <button @click.prevent="clearFile" class="button"><i class="fa fa-trash"></i></button>
                    </div>
                </div>
                <div class="d-flex justify-content-center gap10 pt-3">
                    <button class="button" @click.prevent="saveServices"><i class="fa fa-save mr-2"></i>SAVE</button>
                    <button class="button" @click.prevent="showHideModal(false, 'services')"><i class="fa fa-ban mr-2"></i>CLOSE</button>
                </div>
            </div>
        </div>
        </b-modal>
    </div>
</template>

<script>
import UploadServicesInBulkComponent from './uploadServicesInBulkComponent.vue';

export default {
    components: { UploadServicesInBulkComponent },
    data() {
        return {
            loader: true,
            servicesList: [],
            tabs: [
                {
                    text: 'Services',
                    id: 1,
                    name: 'services'
                },
                {
                    text: 'Service Requests',
                    id: 2,
                    name: 'service_requests'
                },
            ],
            selectedTab: {
                text: 'Services',
                id: 1,
                name: 'services'
            },
            singleData: {
                id: null,
                service_name: null,
                image: null,
                file2: null,
                per_day_price: null,
                per_month_price: null,
            },
            bulkData: [],
            customers: [],
            service_list: [],
            selected_service: null,
            selected_customer: null,
            requested_services_list: [],
            today: false
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchServices()
        await this.fetchCustomers()
        await this.fetchAllServicesRequestedByCustomers()
        this.loader = false
    },
    methods: {
        fetchForToday() {
            this.today = true
            this.fetchAllServicesRequestedByCustomers(this.today)
        },
        async fetchAllServicesRequestedByCustomers(today = false) {
            try {
                let query = `/services/fetch-services-subscription-by-customers`
                let filter = ''
                if (today) {
                    filter = `${filter}today=${today == 1 ? true : false}`
                }
                if (this.selected_customer) {
                    if (filter.length) {
                        filter = `${filter} user_id=${this.selected_customer}`
                    } else {
                        filter = `${filter}user_id=${this.selected_customer}&`
                    }
                }
                if (this.selected_service) {
                    if (filter.length) {
                        filter = `${filter} service_id=${this.selected_service}`
                    } else {
                        filter = `${filter}service_id=${this.selected_service}`
                    }
                }
                const response = await this.$axios.get(`${query}?${filter.replaceAll(' ', '&')}`)
                this.requested_services_list = response.data.data
                this.tabs[1].text = `Service Requests (${response.data.data.length})`
            } catch (error) {
                console.log(error);
            }
        },
        async fetchCustomers() {
            const response = await this.$axios.get('/fetch-customers')
            this.customers = response.data.customers.map(e => {
                return {
                    value: e.id,
                    text: `${e.fullname}`
                }
            })
            this.customers.unshift({
                value: null,
                text: 'Select an user.'
            })
        },
        changeTab(tab) {
            this.selectedTab = tab
        },
        setData(data) {
            this.bulkData = data
        },
        async saveData() {
            try {
                this.loader = true
                const response = await this.$axios({
                    method: 'POST',
                    url: '/services/bulk-upload',
                    data: {
                        services: this.bulkData
                    }
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.hideBulkUploadOption()
                await this.fetchServices()
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        },
        showBulkUploadOption() {
            this.$bvModal.show('bulkUploadServices')
        },
        hideBulkUploadOption() {
            this.setData([])
            this.$bvModal.hide('bulkUploadServices')
        },
        showHideModal(show=true, modal='services') {
            if (show) this.$bvModal.show(modal)
            else {
                this.$bvModal.hide(modal)
                this.singleData = {
                    id: null,
                    service_name: null,
                    image: null,
                    per_day_price: null,
                    per_month_price: null,
                }
            }
        },
        openEdit(data) {
            this.singleData.id = data.id
            this.singleData.service_name = data.name
            this.singleData.per_day_price = data.per_day_price
            this.singleData.per_month_price = data.per_month_price
            this.singleData.image = data.image
            this.showHideModal(true, 'services')
        },
        handleFileInput(event) {
            if (event) {
                this.singleData.image = URL.createObjectURL(event)
            }
        },
        clearFile() {
            this.singleData.image = null
            this.singleData.file2 = null
        },
        async saveServices() {
            if (!this.singleData.service_name || !this.singleData.service_name.trim()) {
                this.$toast.show('Enter a service name.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (this.singleData.per_day_price == null || !`${this.singleData.per_day_price}`.trim()) {
                this.$toast.show('Enter a service cost per day.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (this.singleData.per_month_price == null || !`${this.singleData.per_month_price}`.trim()) {
                this.$toast.show('Enter a service cost per month.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if ((!this.singleData.image || !this.singleData.image.trim()) && !this.singleData.file2) {
                this.$toast.show('Select an image for the service.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            let url = !this.singleData.id ? '/services/add-new-services' : '/services/update-services'
            const form = new FormData()
            form.append('service_name', this.singleData.service_name)
            if (this.singleData.file2) {
                form.append('image', this.singleData.file2)
            }
            form.append('per_day_price', this.singleData.per_day_price)
            form.append('per_month_price', this.singleData.per_month_price)
            if (this.singleData.id) {
                form.append('service_id', this.singleData.id)
            }
            const response = await this.$axios({
                method: 'POST',
                url,
                data: form
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.fetchServices()
            this.showHideModal(false, 'services')
        },
        downloadSample() {
            var a = window.document.createElement("a");
            a.href = '/samples/sampleServiceBulkUpload.csv';
            a.download = 'sample_service_bulk_upload.csv';
            document.body.appendChild(a);
            a.click(); // IE: "Access is denied"; see: https://connect.microsoft.com/IE/feedback/details/797361/ie-10-treats-blob-url-as-cross-origin-and-denies-access
            document.body.removeChild(a);
        },
        async removeService(id) {
            this.deleteService('/services/delete-service', 'service_id', id)
        },
        async deleteService(path, key, data_id) {
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
                            this.$toast.show(deleteresponse.data.message, {
                                duration: 1500,
                                position: 'top-right',
                                keepOnHover: true,
                                type: deleteresponse.data.status
                            })
                            await this.fetchServices()
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
        async fetchServices() {
            const response = await this.$axios.get('/services/fetch-all-services')
            if (response.data.code == 401) {
                await this.logout()
                return false
            }
            this.servicesList = response.data.services
            this.service_list = response.data.services.map(e => {
                return {
                    value: e.id,
                    text: e.name
                }
            })
            this.service_list.unshift({
                value: null,
                text: 'Select a service'
            })
            this.tabs[0].text = `Services (${response.data.services.length})`
        },
        async logout() {
            await this.$auth.logout();
            this.$router.push('/login');
        },
    }
}
</script>