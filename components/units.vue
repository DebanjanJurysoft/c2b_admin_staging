<template>
    <div class="apartmentHolder">
        <div class="addApartment">
            <div class="p-3 text-center">
                <h3>Filter Units</h3>
                <label>Apartment</label>
                <b-form-select class="my-2" v-model="selectedApartment" @change="selectApartment(selectedApartment)" :options="apartmentList" value-field="id" text-field="name"></b-form-select>
                <button v-if="selectedApartment" class="btn btn-success w-100" @click.prevent="$bvModal.show('bulkUpload')">Bulk Upload</button>
                <label v-if="selectedApartment">Floor</label>
                <b-form-select class="my-2" v-model="selectedFloor" @change="getUnitList" v-if="selectedApartment" :options="floorList" value-field="value" text-field="text"></b-form-select>
                <b-modal id="bulkUpload" size="lg" hide-footer hide-header no-close-on-backdrop>
                    <div class="text-center">
                        <h3>Upload Units Data File</h3>
                        <span class="text-danger">* Only accepts .csv file.</span>
                        <BulkUpload :apartment_details="apartment_details" @closeModal="closeBulkUploadModal"/>
                    </div>
                </b-modal>
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
                    <h5 class="card-title">{{ unit.text }}</h5>
                    <button class="btn btn-warning" @click.prevent="selectUnit(unit.id)"><i class="fa fa-pencil"></i> EDIT</button>
                    <!-- <button class="btn btn-danger"><i class="fa fa-trash"></i> DELETE</button> -->
                </div>
            </div>
        </div>
        <div class="unitDetails" v-if="selectedUnitId" style="height: 600px; padding: 10px; overflow-y: scroll; overflow-x: hidden;">
            <div style="text-align: center;">
                <h3>Unit Details ({{ unitDetailsForm.text }})</h3>
                <!-- <pre>{{ unitDetailsForm }}</pre> -->
                <div class="p-1">
                    <input type="text" class="form-control" v-model="unitDetailsForm.unit_id" placeholder="Unit ID">
                </div>
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
import BulkUpload from '~/components/bulkUpload.vue'
import Swal from 'sweetalert2'
import { watch } from 'vue'
export default {
    components: { BulkUpload },
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
                unit_id: null,
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
            apartmentList: [],
            apartment_details: {},
        }
    },
    mounted() {
        this.fetchApartments()
    },
    methods: {
        async closeBulkUploadModal() {
            await this.fetchApartments()
            await this.selectApartment(this.selectedApartment)
            this.$bvModal.hide('bulkUpload')
        },
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
            const unitDetails = await this.getUnitDetails()
            if (unitDetails) {
                this.unitDetailsForm.floor_no = unitDetails.floor_no
            } else if (this.selectedFloor) {
                this.unitDetailsForm.floor_no = this.selectedFloor.num + 1
            } else {
                floor = parseInt(this.selectedUnitId.split(',')[1].replace('FL', ''))
                this.unitDetailsForm.floor_no = floor
            }
            this.unitDetailsForm.id = unitDetails ? unitDetails.id : null
            this.unitDetailsForm.unit_id = unitDetails && unitDetails.unit_id ? unitDetails.unit_id : null
            this.unitDetailsForm.sqft = unitDetails ? unitDetails.sqft : null
            this.unitDetailsForm.sba = unitDetails ? unitDetails.sba : null
            this.unitDetailsForm.price_per_sqft = unitDetails ? unitDetails.price_per_sqft : null
            this.unitDetailsForm.facing = unitDetails ? unitDetails.facing : null
            this.unitDetailsForm.bhk = unitDetails ? unitDetails.bhk : null
            this.unitDetailsForm.amenities = unitDetails ? unitDetails.amenities : null
            this.unitDetailsForm.specification = unitDetails && unitDetails.specification.length > 0 ? unitDetails.specification : [{
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
            console.log(response);
            if (response.data.message.includes('success')) {
                const unit_details = response.data.data[0]
                return unit_details
            }
        },
        getUnitList() {
            if (this.selectedApartment) {
                const apartment = this.apartmentList.find(e => e.id == this.selectedApartment)
                this.unitList = []
                if (apartment.units.length > 0) {
                    if (this.selectedFloor) {
                        this.unitList = apartment.units.filter(e => e.floor_no == this.selectedFloor.num).map(e => {
                            return {
                                id: e.id,
                                text: e.unit_id
                            }
                        })    
                    } else {
                        this.unitList = apartment.units.map(e => {
                            return {
                                id: e.id,
                                text: e.unit_id
                            }
                        })
                    }
                } else {
                    Swal.fire({
                        position: 'top-end',
                        icon: 'warning',
                        title: 'Upload csv file of the unit details.',
                        showConfirmButton: false,
                        timer: 1500
                    })
                    return
                    if (!this.selectedFloor) {
                        for (let floor = 0; floor < apartment.floor_no; floor++) {
                            for (let unit = 0; unit < apartment.floors[floor].units; unit++) {
                                const unitValue = `AP${this.selectedApartment},FL${floor + 1},UN${unit + 1}`
                                this.unitList.push({
                                    id: unitValue,
                                    text: unitValue
                                })
                            }
                        }
                    } else {
                        this.unit_per_floor = this.selectedFloor.e.units
                        for (let unit = 0; unit < this.selectedFloor.e.units; unit++) {
                            const unitValue = `AP${this.selectedApartment},FL${this.selectedFloor.num},UN${unit + 1}`
                            this.unitList.push({
                                id: unitValue,
                                text: unitValue
                            })
                        }
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
            this.apartment_details = apartment
            this.no_of_floor = apartment.floor_no
            this.apartment_name = apartment.name
            const floorNumbers = apartment.floors
            this.floorList = floorNumbers.map(e => {
                return {
                    value: {
                        num: e.floors,
                        e,
                        id
                    },
                    text: e.floors
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
                unit_id: this.unitDetailsForm.unit_id,
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
                unit_id: this.unitDetailsForm.unit_id,
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
            if (this.unitDetailsForm.id) {
                const query = {
                    unit_id: this.selectedUnitId,
                    apt_id: this.selectedApartment,
                    floor_no: this.selectedFloor ? this.selectedFloor.num + 1 : null
                }
                const response_unit = await this.$axios.get('/get-units', { params: query })
                const data = this.unitList.map(e => {
                    if (e.id == this.unitDetailsForm.id) {
                        return {
                            id: response_unit.data.data[0].id,
                            text: response_unit.data.data[0].unit_id
                        }
                    } else {
                        return e
                    }
                })
                this.unitList = await Promise.all(data)
            } else {

            }
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