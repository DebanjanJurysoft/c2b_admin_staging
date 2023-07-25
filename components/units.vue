<template>
    <div class="apartmentHolder">
        <div class="addApartment">
            <div class="p-3 text-center">
                <h3>Filter Units</h3>
                <label>Apartment</label>
                <b-form-select class="my-2" v-model="selectedApartment" @change="selectApartment(selectedApartment)" :options="apartmentList" value-field="id" text-field="name"></b-form-select>
                <label v-if="selectedApartment">Floor</label>
                <b-form-select class="my-2" v-model="selectedFloor" @change="getUnitList" v-if="selectedApartment" :options="floorList" value-field="value" text-field="text"></b-form-select>
            </div>
            <div class="p-3 text-center" v-if="selectedApartment">
                <h3>Apartment details</h3>
                <div class="p-3">
                    <input type="text" class="form-control" disabled v-model="apartment_name" placeholder="Apartment Name">
                </div>
                <div class="p-3">
                    <input type="text" class="form-control" disabled  v-model="no_of_floor" placeholder="Floors In The Appartment">
                </div>
                <div class="p-3">
                    <input type="text" class="form-control" disabled  v-model="unit_per_floor" placeholder="Units Per Floors">
                </div>
                <div class="p-3">
                    <button class="btn btn-danger" @click.prevent="resetForm()" v-if="selectedApartment"><i class="fa fa-ban"></i> CANCEL</button>
                </div>
            </div>
        </div>
        <div class="viewApartment" style="height: 600px; padding: 10px; overflow-y: scroll; width: 30%;">
            <div class="card my-2" style="text-align: center; width: 100%;" v-if="selectedApartment" v-for="(unit, index) in unitList" :key="index">
                <div class="card-body">
                    <h5 class="card-title">{{ unit.id }}</h5>
                    <button class="btn btn-warning" @click.prevent="selectUnit(unit.id)"><i class="fa fa-pencil"></i> EDIT</button>
                    <!-- <button class="btn btn-danger"><i class="fa fa-trash"></i> DELETE</button> -->
                </div>
            </div>
        </div>
        <div class="unitDetails" v-if="selectedUnitId" style="height: 600px; padding: 10px; overflow-y: scroll; overflow-x: hidden;">
            <div style="text-align: center;">
                <h3>Unit Details ({{ selectedUnitId }})</h3>
                <!-- <pre>{{ unitDetailsForm }}</pre> -->
                <div class="p-1">
                    <input type="number" class="form-control" v-model="unitDetailsForm.sqft" placeholder="Square Feet">
                </div>
                <div class="p-1">
                    <input type="number" class="form-control" v-model="unitDetailsForm.sba" placeholder="Super Base Area">
                </div>
                <div class="p-1">
                    <input type="number" class="form-control" v-model="unitDetailsForm.price_per_sqft" placeholder="Price per squarefeet">
                </div>
                <div class="p-1">
                    <input type="number" class="form-control" v-model="unitDetailsForm.bhk" placeholder="BHK">
                </div>
                <div class="p-1">
                    <b-form-select class="my-2" v-model="unitDetailsForm.facing" :options="facing_option_list" value-field="value" text-field="text"></b-form-select>
                </div>
                <div class="p-1">
                    <input type="text" class="form-control" v-model="unitDetailsForm.amenities" placeholder="Amenities (separated by comma)">
                </div>
                <div>
                    <label>Other specification</label>
                    <div v-for="(specs, index) in unitDetailsForm.specification" class="p-1 align-items-center">
                        <input type="text" class="form-control my-1" v-model="specs.key" placeholder="heading">
                        <input type="text" class="form-control my-1" v-model="specs.value" placeholder="value">
                        <div class="justify-center">
                            <button @click.prevent="() => {unitDetailsForm.specification.push({key: null, value: null})}" class="btn btn-outline-success">
                                <i class="fa fa-plus"></i>
                            </button>
                            <button v-if="index != 0" @click.prevent="() => {unitDetailsForm.specification.splice(index, 1)}" class="btn btn-outline-danger">
                                <i class="fa fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>
                <div>
                    <button class="btn btn-success" @click.prevent="saveForm"><i class="fa fa-save"></i> SAVE</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
import { watch } from 'vue'
export default {
    data() {
        return {
            facing_option_list: [
                {
                    value: null,
                    text: 'Select facing direction'
                },
                {
                    value: 'EAST',
                    text: 'EAST'
                },
                {
                    value: 'WEST',
                    text: 'WEST'
                },
                {
                    value: 'NORTH',
                    text: 'NORTH'
                },
                {
                    value: 'SOUTH',
                    text: 'SOUTH'
                },
            ],
            unitDetailsForm: {
                id: null,
                apt_id: null,
                floor_no: null,
                sqft: null,
                sba: null,
                price_per_sqft: null,
                facing: null,
                bhk: null,
                amenities: null,
                specification: [
                    {
                        value: null,
                        key: null,
                    }
                ]
            },
            selectedUnitId: null,
            addApartment: true,
            viewApartment: true,
            updateApartment: false,
            apartment_name: null,
            no_of_floor: null,
            unit_per_floor: null,
            selectedFloor: null,
            selectedApartment: null,
            unitList: [],
            floorList: [],
            apartmentList: [
            ]
        }
    },
    mounted() {
        this.fetchApartments()
    },
    methods: {
        async fetchApartments() { 
            const response = await this.$axios.get('/get-apartments')
            this.apartmentList = response.data.data
            this.apartmentList.unshift({
                id: null,
                name: 'Select a apartment',
            })
        },
        async selectUnit(id) {
            this.selectedUnitId = id
            this.resetDetailsForm()
            this.unitDetailsForm.apt_id = this.selectedApartment
            let floor = null
            const user_details = await this.getUnitDetails()
            if (user_details) {
                this.unitDetailsForm.floor_no = user_details.floor_no
            } else if (this.selectedFloor) {
                this.unitDetailsForm.floor_no = this.selectedFloor.num + 1
            } else {
                floor = parseInt(this.selectedUnitId.split(',')[1].replace('FL', ''))
                this.unitDetailsForm.floor_no = floor
            }
            this.unitDetailsForm.id = user_details ? user_details.id : null
            this.unitDetailsForm.sqft = user_details ? user_details.sqft : null
            this.unitDetailsForm.sba = user_details ? user_details.sba : null
            this.unitDetailsForm.price_per_sqft = user_details ? user_details.price_per_sqft : null
            this.unitDetailsForm.facing = user_details ? user_details.facing : null
            this.unitDetailsForm.bhk = user_details ? user_details.bhk : null
            this.unitDetailsForm.amenities = user_details ? user_details.amenities : null
            this.unitDetailsForm.specification = user_details ? user_details.specification : [{
                key: null,
                value: null
            }]
        },
        async getUnitDetails() {
            const query = {
                unit_id: this.selectedUnitId,
                apt_id: this.selectedApartment,
                floor_no: this.selectedFloor ? this.selectedFloor.num + 1 : null
            }
            const response = await this.$axios.get('/get-units', {
                params: query
            })
            if (response.data.message.includes('success')) {
                const unit_details = response.data.data[0]
                return unit_details
            }
        },
        getUnitList() {
            if (this.selectedApartment) {
                const apartment = this.apartmentList.find(e => e.id == this.selectedApartment)
                if (!this.selectedFloor) {
                    this.unitList = []
                    for (let floor = 0; floor < apartment.floor_no; floor++) {
                        for (let unit = 0; unit < apartment.unit_per_floor; unit++) {
                            const unitValue = `AP${this.selectedApartment},FL${floor+1},UN${unit+1}`
                            this.unitList.push({
                                id: unitValue,
                                text: unitValue
                            })
                        }
                    }
                } else {
                    this.unitList = []
                    for (let unit = 0; unit < apartment.unit_per_floor; unit++) {
                        const unitValue = `AP${this.selectedApartment},FL${this.selectedFloor.num+1},UN${unit+1}`
                        this.unitList.push({
                            id: unitValue,
                            text: unitValue
                        })
                    }
                }
            }
        },
        resetDetailsForm() { 
            this.unitDetailsForm = {
                id: null,
                apt_id: null,
                floor_no: null,
                sqft: null,
                sba: null,
                price_per_sqft: null,
                facing: null,
                bhk: null,
                specification: [
                    {
                        value: null,
                        key: null,
                    }
                ],
                amenities: null
            }
        },
        resetForm() { 
            this.edit_id = null
            this.apartment_name = null
            this.no_of_floor = null
            this.unit_per_floor = null
            this.selectedApartment = null
            this.selectedFloor = null
            this.selectedUnitId = null
        },
        selectApartment(id) {
            const apartment = this.apartmentList.find(e => e.id == id)
            this.apartment_name = apartment.name
            this.no_of_floor = apartment.floor_no
            this.unit_per_floor = apartment.unit_per_floor
            const floorNumbers = Array.from(Array(apartment.floor_no).keys())
            this.floorList = floorNumbers.map(e => {
                return {
                    value: {
                        num: e,
                        id
                    },
                    text: e + 1
                }
            })
            this.floorList.unshift({
                value: null,
                text: 'select a floor'
            })
            this.getUnitList()
        },
        async saveForm() {
            this.unitDetailsForm = this.unitDetailsForm.id ? {
                id: this.unitDetailsForm.id,
                apt_id: this.unitDetailsForm.apt_id,
                floor_no: this.unitDetailsForm.floor_no,
                sqft: this.unitDetailsForm.sqft,
                sba: this.unitDetailsForm.sba,
                price_per_sqft: this.unitDetailsForm.price_per_sqft,
                facing: this.unitDetailsForm.facing,
                bhk: this.unitDetailsForm.bhk,
                amenities: this.unitDetailsForm.amenities,
                specification: this.unitDetailsForm.specification.filter(e => e.value && e.key).map(e => {
                    return {
                        id: e.id ? e.id : null,
                        value: e.value,
                        key: e.key
                    }
                }),
            } : {
                unit_id: this.selectedUnitId,
                apt_id: this.unitDetailsForm.apt_id,
                floor_no: this.unitDetailsForm.floor_no,
                sqft: this.unitDetailsForm.sqft,
                sba: this.unitDetailsForm.sba,
                price_per_sqft: this.unitDetailsForm.price_per_sqft,
                facing: this.unitDetailsForm.facing,
                bhk: this.unitDetailsForm.bhk,
                amenities: this.unitDetailsForm.amenities,
                specification: this.unitDetailsForm.specification.map(e => {
                    if (e.id) {
                        return e
                    } else {
                        return {id: null, ...e}
                    }
                }),
            }
            const response = await this.$axios.post(this.unitDetailsForm.id ? '/update-unit' : '/add-unit', this.unitDetailsForm)
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? 'success' : 'error',
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
        }
    },
}
</script>

<style>
.apartmentHolder {
    width: 100%;
    height: max-content;
    display: flex;
}
.addApartment {
    width: 40%;
    float: left;
}

.viewApartment {
    float: left;
}
.unitDetails {
    width: 30%;
    float: left;
}
</style>