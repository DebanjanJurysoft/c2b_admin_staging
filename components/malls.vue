<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="w100 d-flex flex-row gap16">
                <div class="w50 d-flex flex-column gap16">
                    <div class="d-flex flex-row justify-content-between">
                        <span class="text-heading fontSize25">Malls</span>
                        <span class="button" @click.prevent="addMall">
                            <i class="fa fa-plus mr-2"></i>
                            malls
                        </span>
                    </div>
                    <div class="sub-category-form d-flex flex-column border" 
                        style="
                            background: white !important;
                        "
                        v-for="(mall, mall_index) in malls_list"
                        :key="mall_index"
                    >
                        <div class="d-flex flex-row justify-content-between w100">
                            <span class="text-heading fontSize20 w80" style="padding-left: 0px;"><strong class="pr-2"><strong>Name: </strong></strong>{{ mall.name }}</span>
                            <div class="w20 d-flex flex-row-reverse gap10">
                                <span @click.prevent="editMall(mall)" class="plan-edit-delete-button plan-button-edit">
                                    <i class="fa fa-pencil"></i>
                                </span>
                                <span @click.prevent="deleteMall(mall.id)" class="plan-edit-delete-button plan-button-delete">
                                    <i class="fa fa-trash"></i>
                                </span>
                            </div>
                        </div>
                        <div class="d-flex flex-row w100"
                        @click.prevent="() => {
                            if (mall.stores_in_mall.length) {
                                showStores(mall)
                            } else {
                                $toast.show('No stores in the mall.', {
                                    duration: 1500,
                                    position: 'top-right',
                                    keepOnHover: true, 
                                    type: 'error'
                                })
                            }
                        }"
                        >
                            <div class="w20 d-flex flex-row">
                                <img style="width: 100px !important; object-fit: scale-down !important;" :src="mall.image_url" alt="Mall Image">
                            </div>
                            <div class="w80 d-flex flex-column">
                                <span class="text-heading fontSize16"><strong><strong>address: </strong></strong>{{ mall.address }}</span>
                                <div class="d-flex  justify-content-between">
                                    <span class="text-heading fontSize16"><strong><strong>Available Stores: </strong></strong>{{ mall.stores_in_mall.length }}</span>
                                </div>
                                <div class="d-flex flex-row justify-content-between">
                                    <span class="text-heading w50 fontSize14">
                                        <strong class="pr-3"><strong>Lattitude</strong></strong>
                                        <span>{{ mall.lat }}</span>
                                    </span>
                                    <span class="text-heading w50 fontSize14">
                                        <strong class="pr-3"><strong>Longitude</strong></strong>
                                        <span>{{ mall.lng }}</span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <b-modal
                    id="mallStores" 
                    hide-footer 
                    hide-header 
                    no-close-on-backdrop 
                    centered 
                ><div class="d-flex flex-row align-items-center justify-content-between" v-if="selected_mall">
                        <span class="text-heading">Stores in ({{ selected_mall.name }})</span>
                        <span class="text-danger cursor-pointer" @click.prevent="closeModal"><i class="fa fa-times mr-1"></i></span>
                    </div>
                    <div class="d-flex flex-column" v-if="selected_mall">
                        <span class="text-heading" v-for="(store, store_index) in selected_mall.stores_in_mall" :key="store_index">{{ `${store_index + 1}. ${store.store.name}` }}</span>
                    </div>
                </b-modal>
                <div class="w50 d-flex flex-column" v-if="showForm">
                    <div class="d-flex flex-row justify-content-between mb-3 py-3">
                        <span class="text-heading fontSize25">{{ form_title }}</span>
                        <span @click.prevent="closeForm" class="plan-edit-delete-button plan-button-delete">
                            <i class="fa fa-times"></i>
                        </span>
                    </div>
                    <div class="sub-category-form border d-flex flex-column" style="background: white;">
                        <div class="d-flex flex-column w100">
                            <div class="d-flex flex-column w100">
                                <div class="d-flex flex-row w100">
                                    <span class="text-heading" style="padding-left: 0px;">Mall Name:</span>
                                </div>
                                <div class="d-flex flex-row w100">
                                    <b-form-input v-model="mall_data.name" placeholder="Mall Name"></b-form-input>
                                </div>
                            </div>
                            <div class="d-flex flex-column w100">
                                <div class="d-flex flex-row w100">
                                    <span class="text-heading" style="padding-left: 0px;">Mall Address:</span>
                                </div>
                                <div class="d-flex flex-row w100">
                                    <b-form-textarea
                                        v-model="mall_data.address"
                                        id="textarea"
                                        placeholder="Mall Address"
                                        rows="3"
                                        max-rows="6"
                                    ></b-form-textarea>
                                </div>
                            </div>
                            <div class="d-flex flex-row w100 gap16">
                                <div class="d-flex flex-column w50">
                                    <div class="d-flex flex-row w100">
                                        <span class="text-heading" style="padding-left: 0px;">Mall Lattitude:</span>
                                    </div>
                                    <div class="d-flex flex-row w100">
                                        <b-form-input v-model="mall_data.lat" placeholder="Mall Lattitude"></b-form-input>
                                    </div>
                                </div>
                                <div class="d-flex flex-column w50">
                                    <div class="d-flex flex-row w100">
                                        <span class="text-heading" style="padding-left: 0px;">Mall Longitude:</span>
                                    </div>
                                    <div class="d-flex flex-row w100">
                                        <b-form-input v-model="mall_data.lng" placeholder="Mall Longitude"></b-form-input>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-column w100">
                                <div class="d-flex flex-row w100">
                                    <span class="text-heading" style="padding-left: 0px;">Mall Image:</span>
                                </div>
                                <div class="d-flex flex-row">
                                    <div class="d-flex flex-row w70">
                                        <b-form-file @input="handleMallImage($event)" v-model="mall_data.image" placeholder="Choose Mall Image" plain></b-form-file>
                                    </div>
                                    <div class="d-flex flex-row" v-if="mall_data.image_url">
                                        <img style="width: 100px; border-radius: 16px;" :src="mall_data.image_url" alt="MallImage">
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-row w100 justify-content-center py-3">
                                <button class="button" @click.prevent="saveMall"><i class="fa fa-save mr-2"></i>Save</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            loader: true,
            malls_list: [],
            form_title: 'Add New Mall',
            edit_id: null,
            mall_data: {
                name: null,
                address: null,
                image: null,
                image_url: null,
                lat: null,
                lng: null,
            },
            showForm: false,
            selected_mall: null
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchMalls()
        this.loader = false
    },
    props: ['searchText'],
    watch: {
        searchText(val) {
                clearTimeout(this.timer)
                this.timer = setTimeout(async () => {
                    this.loader = true
                    await this.fetchMalls()
                    this.loader = false
                }, 300);
            }
    },
    methods: {
        showStores(data) {
            this.selected_mall = data
            this.$bvModal.show('mallStores')
        },
        closeModal() {
            this.$bvModal.hide('mallStores')
        },
        async logout() {
            await this.$auth.logout()
            this.$router.push('/login')
        },
        handleMallImage(event) { 
            this.mall_data.image_url = URL.createObjectURL(event)
        },
        async saveMall() {
            this.loader = true
            try {
                let data = {
                    name: this.mall_data.name,
                    address: this.mall_data.address,
                    image: this.mall_data.image,
                    lat: this.mall_data.lat,
                    lng: this.mall_data.lng,
                }
                if (this.edit_id) {
                    data['mall_id'] = this.edit_id
                }
                const formData = new FormData()
                for (const key of Object.keys(data)) {
                    formData.append(key, data[key])
                }
                const response = await this.$axios({
                    method: 'POST',
                    url: this.edit_id ? '/update-mall' : '/create-mall',
                    data: formData
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
                await this.fetchMalls()
                this.$emit('reloadDashboard')
                this.closeForm()
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async fetchMalls() {
            try {
                let path = '/get-malls'
                if (this.searchText) {
                    path = `${path}?q=${this.searchText}`
                }
                const response = await this.$axios.get(path)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.malls_list = response.data.malls
            } catch (error) {
                console.log(error);
            }
        },
        addMall() {
            this.form_title = `Add new mall`
            this.edit_id = null
            this.mall_data = {
                name: null,
                address: null,
                lat: null,
                lng: null,
                image_url: null,
                image: null,
            }
            this.showForm = true
        },
        editMall(mall) {
            this.form_title = `Edit ${mall.name} Mall`
            this.edit_id = mall.id
            this.mall_data = {
                name: mall.name,
                address: mall.address,
                lat: mall.lat,
                lng: mall.lng,
                image_url: mall.image_url,
                image: null,
            }
            this.showForm = true
        },
        closeForm() {
            this.edit_id =null
            this.mall_data = {
                name: null,
                address: null,
                lat: null,
                lng: null,
                image_url: null,
                image: null,
            }
            this.showForm = false
        },
        deleteMall(id) {
            const path = '/delete-mall'
            this.deleteWithPopup(path, 'mall_id', id)
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
                            this.$toast.show(deleteresponse.data.message, {
                                duration: 1500,
                                position: 'top-right',
                                keepOnHover: true,
                                type: deleteresponse.data.status
                            })
                            await this.fetchMalls()
                            this.$emit('reloadDashboard')
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
    }
}
</script>

<style>
    .plan-edit-delete-button {
        /* padding: 8px !important; */
        height: 40px !important;
        width: 40px !important;
        display: flex !important;
        justify-content: center !important;
        align-items: center !important;
        border-radius: 50% !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
    }
    .plan-button-delete {
        background: rgb(255, 30, 30) !important;
        color: white !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
    }
    .plan-button-delete:hover {
        box-shadow: rgb(255, 0, 0) 0px 5px 25px !important;
        color: white !important;
    }
    .plan-button-edit {
        background: rgb(34, 108, 255) !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
        color: white !important;
    }
    .plan-button-edit:hover {
        box-shadow: rgb(0, 85, 255) 0px 5px 25px !important;
        color: white !important;
    }
    .plan-button-add {
        background: rgb(41, 255, 34) !important;
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px !important;
        color: white !important;
    }
    .plan-button-add:hover {
        box-shadow: rgb(9, 255, 0) 0px 5px 25px !important;
        color: white !important;
    }
    .sm {
        height: 30px !important;
        width: 30px !important;
    }
</style>