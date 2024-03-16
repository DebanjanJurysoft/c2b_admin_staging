<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-else class="pl-3 pr-3">
            <div class="d-flex">
                <div class="tab-items" @click.prevent="changeTab(tab)"
                    :class="selectedTab.id == tab.id ? 'tab-items-active' : ''" v-for="(tab, index) in tabs"
                    :key="index">
                    <span>{{ tab.text }}</span>
                </div>
            </div>
            <div class="d-flex flex-column gap10 py-3 px-3">
                <div class="d-flex flex-row-reverse gap10 align-items-center">
                    <button class="button" @click.prevent="openAddServiceProviderPopup"><i
                            class="fa fa-plus mr-2"></i>Add New Service Provider</button>
                    <button class="button" @click.prevent="openAddServiceProviderBulkPopup"><i
                            class="fa fa-plus mr-2"></i>Add New Service Provider in bulk</button>
                </div>
            </div>
            <div>
                <table class="table table-hover" v-if="service_provider_list.length == 0">
                    <tr class="text-center h4">
                        No Record Found
                    </tr>
                </table>
                <table class="main-table" v-else>
                    <thead>
                        <th class="heading">SL No.</th>
                        <th class="heading">Service Provider Name</th>
                        <th class="heading">Service Provider Shop Name</th>
                        <th class="heading">Service Provider Email</th>
                        <th class="heading">Service Provider Phone</th>
                        <th class="heading">Service Provider Alternative Phone</th>
                        <th class="heading">Services</th>
                        <th class="heading">Action</th>
                    </thead>
                    <tbody>
                        <tr class="table-rows" v-for="(service_providers, sp_index) in service_provider_list">
                            <td>{{ sp_index + 1 }}</td>
                            <td>{{ service_providers.fullname }}</td>
                            <td>{{ service_providers.shopname }}</td>
                            <td>{{ service_providers.email }}</td>
                            <td>{{ service_providers.phone }}</td>
                            <td>{{ service_providers.alt_phone }}</td>
                            <td v-if="service_providers.services.length">
                                <div class="d-flex flex-column gap10">
                                    <template v-for="(service, index) in service_providers.services">
                                        <div class="d-flex align-items-center">
                                            <img width="30" :src="service.image" :alt="service.name">
                                            <span class="ml-2">{{ service.name }}</span>
                                        </div>
                                    </template>
                                </div>
                            </td>
                            <td>
                                <div class="d-flex flex-column gap8">
                                    <button class="button bg-success" v-if="selectedTab.id != 2" @click.prevent="acceptRejectServiceProvider(service_providers.id, true)">
                                        <i class="fa fa-check mr-2"></i>
                                        approve
                                    </button>
                                    <button class="button bg-danger" v-if="selectedTab.id != 3" @click.prevent="acceptRejectServiceProvider(service_providers.id, false)">
                                        <i class="fa fa-ban mr-2"></i>
                                        Reject
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <b-modal size="lg" id="ServiceProviders" hide-footer hide-header no-close-on-backdrop centered>
                <div class="d-flex flex-column">
                    <div class="d-flex justify-content-between align-items-center">
                        <h3 class="ml-2">New Service Provider Registration</h3>
                        <i class="fa fa-times pointer text-danger fontSize25 mr-2" @click.prevent="closeAddServiceProviderPopup"></i>
                    </div>
                    <div class="d-flex flex-column sub-category-form gap10 border mb-3">
                        <div class="d-flex flex-column gap8">
                            <span class="fontSize15 input-label">Service Provider Full Name:</span>
                            <input type="text" class="form-control" v-model="form_data_for_single_service_provider.fullname" placeholder="Service Provider Name">
                        </div>
                        <div class="d-flex gap8">
                            <div class="d-flex flex-column gap8 w-50">
                                <span class="fontSize15 input-label">Service Provider Shop Name:</span>
                                <input type="text" class="form-control" v-model="form_data_for_single_service_provider.shopname" placeholder="Service Provider Shop Name">
                            </div>
                            <div class="d-flex flex-column gap8 w-50">
                                <span class="fontSize15 input-label">Services:</span>
                                <vSelect :options="service_list" v-model="form_data_for_single_service_provider.selectedServices" multiple label="text"></vSelect>
                            </div>
                        </div>
                        <div class="d-flex flex-column gap8">
                            <span class="fontSize15 input-label">Email:</span>
                            <input type="text" v-model="form_data_for_single_service_provider.email" class="form-control"  placeholder="Email">
                        </div>
                        <div class="d-flex gap8">
                            <div class="d-flex flex-column gap8 w-50">
                                <span class="fontSize15 input-label">Phone Number:</span>
                                <input type="text" v-model="form_data_for_single_service_provider.phone" class="form-control" placeholder="Phone Number">
                            </div>
                            <div class="d-flex flex-column gap8 w-50">
                                <span class="fontSize15 input-label">Alternate Phone Number:</span>
                                <input type="text" class="form-control" v-model="form_data_for_single_service_provider.alt_phone" placeholder="Alternate Phone Number">
                            </div>
                        </div>
                        <div class="d-flex flex-column gap8 sub-category-form border">
                            <div class="d-flex flex-column gap8">
                                <h3 class="input-label fontSize25">Address Details</h3>
                                <div class="d-flex gap8">
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Address 1:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.add1" placeholder="Address 1">
                                    </div>
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Address 2:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.add2" placeholder="Address 2">
                                    </div>
                                </div>
                                <div class="d-flex gap8">
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">City:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.city" placeholder="City">
                                    </div>
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Area:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.area" placeholder="Area">
                                    </div>
                                </div>
                                <div class="d-flex gap8">
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">State:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.state" placeholder="State">
                                    </div>
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Country:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.country" placeholder="Country">
                                    </div>
                                </div>
                                <div class="d-flex gap8">
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">PIN Code:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.pin" placeholder="PIN Code">
                                    </div>
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Landmark:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.landmark" placeholder="Landmark">
                                    </div>
                                </div>
                                <div class="d-flex gap8">
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Lattitude:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.lat" placeholder="Lattitude">
                                    </div>
                                    <div class="d-flex flex-column gap8 w-50">
                                        <span class="fontSize15 input-label">Longitude:</span>
                                        <input type="text" class="form-control" v-model="form_data_for_single_service_provider.lng" placeholder="Longitude">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex justify-content-center gap10">
                        <button class="button" @click.prevent="closeAddServiceProviderPopup"><i class="fa fa-ban mr-2"></i>Close</button>
                        <button class="button" @click.prevent="SaveSingleServiceProvider"><i class="fa fa-save mr-2"></i>Save</button>
                    </div>
                </div>
            </b-modal>
        </div>
    </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
    components: {
        vSelect
    },
    data() {
        return {
            loader: false,
            tabs: [
                {
                    text: 'Waiting Service Providers',
                    id: 1,
                    name: 'services'
                },
                {
                    text: 'Approved Service Providers',
                    id: 2,
                    name: 'services'
                },
                {
                    text: 'Rejected Service Providers',
                    id: 3,
                    name: 'rejected_service_providers'
                }
            ],
            service_list: [],
            selectedTab: {
                text: 'Services',
                id: 1,
                name: 'services'
            },
            service_provider_list: [],
            form_data_for_single_service_provider: {
                fullname: 'Debanjan Dasgupta',
                selectedServices: [],
                shopname: 'Debanjan IT Services',
                email: 'Debanjan@it.com',
                phone: '1234567890',
                alt_phone: '1234567890',
                add1: 'Debanjan IT Services',
                add2: 'Debanjan IT Services',
                city: 'Bangalore',
                area: 'RR Nagar',
                country: 'INDIA',
                pin: '560098',
                state: 'Karnataka',
                landmark: 'Debanjan IT Services',
                lat: 12.23456,
                lng: 77.45621,
            }
        }
    },
    async mounted() {
        this.loader= true
        await this.fetchServiceProviders()
        this.loader= false
    },
    methods: {
        async acceptRejectServiceProvider(id = null, approve = null) {
            this.loader = true
            if (approve == null || id == null) {
                this.$toast.show('Provide a valid service Provider id and approve value', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
            } else {
                const response = await this.$axios({
                    method: 'post',
                    url: `/services/approve-reject-service-providers`,
                    data: {
                        service_provider_id: id,
                        approved: approve
                    }
                })
                console.log(response);
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
            await this.fetchServiceProviders()
            this.loader = false
        },
        async fetchServices() {
            this.loader = true
            const response = await this.$axios.get('/services/fetch-all-services')
            if (response.data.code == 401) {
                await this.logout()
                return false
            }
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
            this.loader = false
        },
        async logout() {
            await this.$auth.logout();
            this.$router.push('/login');
        },
        async changeTab(tab) {
            this.selectedTab = tab
            await this.fetchServiceProviders()
        },
        async openAddServiceProviderPopup() {
            this.loader = true
            await this.fetchServices()
            this.$bvModal.show('ServiceProviders')
            this.loader = false
        },
        openAddServiceProviderBulkPopup() {
            this.$bvModal.show('ServiceProviders')
        },
        closeAddServiceProviderPopup() {
            this.$bvModal.hide('ServiceProviders')
            this.form_data_for_single_service_provider.selectedServices = []
        },
        closeAddServiceProviderBulkPopup() {
            this.$bvModal.hide('ServiceProviders')
        },
        async fetchServiceProviders() {
            this.loader = true
            let query = '/services/get-service-providers'
            if (this.selectedTab.id == 2) {
                query = `${query}?approved=true`
            }
            if (this.selectedTab.id == 3) {
                query = `${query}?approved=false`
            }
            const response = await this.$axios.get(query)
            if (response.data.code == 401) {
                await this.logout()
                return false
            }
            this.service_provider_list = response.data.service_providers
            this.loader = false
        },
        async SaveSingleServiceProvider() {
            this.loader = true
            const services = this.form_data_for_single_service_provider.selectedServices.map(e => {
                return {
                    id: e.value
                }
            })
            const services_list = await Promise.all(services)
            this.form_data_for_single_service_provider.selectedServices = services_list
            const response = await this.$axios({
                method: 'post',
                url: `/services/save-service-providers`,
                data: this.form_data_for_single_service_provider
            })
            console.log(response);
            if (response.data.code == 401) {
                await this.logout()
            }
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.closeAddServiceProviderPopup()
            await this.fetchServiceProviders()
            this.loader = false
        }
    }
}
</script>