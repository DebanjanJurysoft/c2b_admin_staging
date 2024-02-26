<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-else class="pl-3 pr-3">
            <div class="d-flex flex-row-reverse py-3 px-3">
                <button class="button" @click.prevent="showHideModal(true, 'services')"><i class="fa fa-plus"></i></button>
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
                    <th style="text-transform: uppercase;">Price Per Day</th>
                    <th style="text-transform: uppercase;">Price Per Month</th>
                    <th style="text-transform: uppercase; text-align: center;">Action</th>
                </thead>
                <tbody>
                    <tr v-for="(service, service_index) in servicesList">
                        <td>{{ service_index + 1 }}</td>
                        <td>{{ service.name }}</td>
                        <td>{{ service.per_day_price }}</td>
                        <td>{{ service.per_month_price }}</td>
                        <td class="d-flex justify-content-center lign-items-center gap10">
                            <button class="button" @click.prevent="openEdit(service)"><i class="fa fa-pencil"></i></button>
                            <button class="button" @click.prevent="removeService(service.id)"><i class="fa fa-trash"></i></button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
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
export default {
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
            }
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchServices()
        this.loader = false
    },
    methods: {
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
            if (!this.singleData.per_day_price || !`${this.singleData.per_day_price}`.trim()) {
                this.$toast.show('Enter a service cost per day.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (!this.singleData.per_month_price || !`${this.singleData.per_month_price}`.trim()) {
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
        },
        async logout() {
            await this.$auth.logout();
            this.$router.push('/login');
        },
    }
}
</script>