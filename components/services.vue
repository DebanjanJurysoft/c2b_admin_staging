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
                            <button class="button"><i class="fa fa-trash"></i></button>
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