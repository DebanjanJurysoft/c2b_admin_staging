<template>
    <div class="w-100 apartmentHolder">
        <div class="addApartment">
            <div class="p-3 text-center">
                <h3>{{ `${addApartment ? 'Add' : 'Update'} Apartment` }}</h3>
                <div class="p-3">
                    <input type="text" class="form-control" v-model="apartment_name" placeholder="Apartment Name">
                </div>
                <div class="p-3">
                    <input type="number" class="form-control" @input="() => {floor_list = Array.from(Array(parseInt(no_of_floor ? no_of_floor : 0)).keys()).map(e => { return {floors: e+1, units: 0, disabled: false}})}" v-model="no_of_floor" placeholder="Floors In The Appartment">
                </div>
                <div style="height: 300px; overflow-x: hidden; overflow: auto;">
                    <div class="p-3 d-flex" v-if="floor_list.length > 0" v-for="(floor, index) in floor_list">
                        <label class="col-6">Units (FL-{{ floor.floors}})</label>
                        <input class="col-4 form-control" @input="changeAll" :disabled="floor.disabled" type="number" v-model="floor.units">
                    </div>
                </div>
                <div>
                    <b-checkbox v-model="same_for_all" @change="sameForAll" v-if="floor_list.length > 0">Same For All</b-checkbox>
                </div>
                <div class="p-3">
                    <button class="btn btn-danger" @click.prevent="resetForm()" v-if="updateApartment"><i class="fa fa-ban"></i> CANCEL</button>
                    <button class="btn btn-success" @click.prevent="saveForm()"><i class="fa fa-save"></i> SAVE</button>
                </div>
            </div>
        </div>
        <div class="viewApartment" style="height: 500px; padding: 30px; overflow-y: scroll;" v-if="apartmentList.length > 0">
            <div class="card my-2" style="width: 100%;" v-for="(apartment, index) in apartmentList" :key="index">
                <div class="card-body"> 
                    <h5 class="card-title">{{ apartment.name }}</h5>
                    <p class="card-text">Number of floors: {{ apartment.floor_no }}</p>
                    <p class="card-text">Total units: {{ apartment.total_units }}</p>
                    <button class="btn btn-warning" @click.prevent="editApartment(apartment.id)"><i class="fa fa-pencil"></i> EDIT</button>
                    <button class="btn btn-danger" @click.prevent="deleteApartment(apartment.id)"><i class="fa fa-trash"></i> DELETE</button>
                </div>
            </div>
        </div>
        <div class="viewApartment" v-else>
            <div class="card my-2">
                <div class="card-body">
                    <h5 class="card-title">No Apartments found.</h5>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
export default {
    data() {
        return {
            addApartment: true,
            same_for_all: false,
            viewApartment: true,
            updateApartment: false,
            apartment_name: null,
            no_of_floor: null,
            unit_per_floor: null,
            edit_id: null,
            apartmentList: [],
            floor_list: []
        }
    },
    mounted() { 
        this.fetchApartments()
    },
    methods: {
        changeAll() { 
            if (this.same_for_all) {
                this.floor_list.forEach((e, i) => {
                    e.units = this.floor_list[0].units ? this.floor_list[0].units : 0
                })
            }
        },
        sameForAll() { 
            if (this.same_for_all) {
                this.floor_list.forEach((e, i) => {
                    if (this.floor_list[0].units) {
                        e.units = this.floor_list[0].units
                    }
                    if (i != 0) {
                        e.disabled = true
                    }
                })
            } else {
                this.floor_list.forEach(e => {
                    e.disabled = false
                })
            }
        },
        async fetchApartments() { 
            const response = await this.$axios.get('/get-apartments')
            this.apartmentList = response.data.data.map(e => { 
                let  totalUnits = 0
                e.floors.forEach(elm => {
                    totalUnits += parseInt(elm.units)
                })
                return {
                    ...e, 
                    total_units: totalUnits
                }
            })
        },
        deleteApartment(id) {
            Swal.fire({
                title: 'Are you sure?',
                text: "You won't be able to revert this!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, delete it!'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    const response = await this.$axios.post('/delete-apartment', {
                        id: id
                    })
                    console.log(response);
                    Swal.fire({
                        position: 'top-end',
                        icon: response.data.message.includes('success') ? 'success' : 'error',
                        title: response.data.message,
                        showConfirmButton: false,
                        timer: 1500
                    })
                    this.fetchApartments()
                }
            })
        },
        resetForm() { 
            this.apartment_name = null
            this.no_of_floor = null
            this.unit_per_floor = null
            this.updateApartment = false
            this.addApartment = true
            this.floor_list = []
        },
        editApartment(id) {
            const selectedApartment = this.apartmentList.find(e => e.id == id)
            console.log(selectedApartment);
            this.edit_id = id
            this.apartment_name = selectedApartment.name
            this.no_of_floor = selectedApartment.floor_no
            this.unit_per_floor = selectedApartment.unit_per_floor
            this.floor_list = selectedApartment.floors
            this.updateApartment = true
            this.addApartment = false
        },
        async saveForm() {
            if (!this.apartment_name || !this.apartment_name.trim()) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter apartment name.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (!this.no_of_floor || !`${this.no_of_floor}`.trim()) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter number of floors.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (!this.floor_list.length > 0 || this.floor_list.filter(e => e.units == 0).length > 0 ) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter unit no for each floor.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            let payload = {}
            if (this.updateApartment) {
                payload = {
                    id: this.edit_id,
                    name: this.apartment_name,
                    floor_no: this.no_of_floor,
                    unit_per_floor_data: this.floor_list.map(e => {
                        return {
                            id: e.id,
                            floor_no: parseInt(e.floors),
                            unit_no: parseInt(e.units)
                        }
                    })
                }
                const response = await this.$axios.post('/update-apartment', payload)
                Swal.fire({
                    position: 'top-end',
                    icon: response.data.message.includes('success') ? 'success' : 'error',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.resetForm()
                this.fetchApartments()
            } else {
                payload = {
                    name: this.apartment_name,
                    floor_no: this.no_of_floor,
                    unit_per_floor_data: this.floor_list.map(e => {
                        return {
                            floor_no: e.floors,
                            unit_no: parseInt(e.units)
                        }
                    })
                }
                // console.log(payload);
                const response = await this.$axios.post('/add-apartment', payload)
                Swal.fire({
                    position: 'top-end',
                    icon: response.data.message.includes('success') ? 'success' : 'error',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.resetForm()
                this.fetchApartments()
            }
        }
    }
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
    width: 60%;
    float: left;
}
</style>