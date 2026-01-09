// ==================== RENTAL SYSTEM UI v2.1 ====================
// Complete Professional Vehicle Rental System Interface

// ==================== GLOBAL STATE ====================
const RentalUI = {
    vehicles: [],
    locations: [],
    selectedVehicle: null,
    selectedDays: 1,
    hasInsurance: false,
    isAdmin: false,
    modalCallback: null,
    
    init() {
        this.setupEventListeners();
        this.loadVehicles();
        this.loadLocations();
        console.log('[RENTAL-UI v2.1] System initialized successfully');
    },
    
    setupEventListeners() {
        // Admin button
        const adminBtn = document.getElementById('adminBtn');
        if (adminBtn) {
            adminBtn.addEventListener('click', () => this.toggleAdmin());
        }
        
        // Close button
        const closeBtn = document.getElementById('closeBtn');
        if (closeBtn) {
            closeBtn.addEventListener('click', () => this.hideUI());
        }
        
        // Admin tabs
        document.querySelectorAll('.admin-tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.switchAdminTab(e.target.closest('.admin-tab-btn')));
        });
        
        // Duration selection
        document.addEventListener('change', (e) => {
            if (e.target.id === 'rentalDays') {
                this.updateCostCalculation();
            }
            if (e.target.id === 'insuranceCheck') {
                this.updateCostCalculation();
            }
        });
        
        // Search and filter
        const searchInput = document.getElementById('vehicleSearch');
        if (searchInput) {
            searchInput.addEventListener('input', (e) => this.filterVehicles(e.target.value));
        }
        
        const categoryFilter = document.getElementById('categoryFilter');
        if (categoryFilter) {
            categoryFilter.addEventListener('change', (e) => this.filterVehicles(null, e.target.value));
        }
        
        // Rental form submission
        const rentalForm = document.getElementById('rentalForm');
        if (rentalForm) {
            rentalForm.addEventListener('submit', (e) => this.submitRental(e));
        }
    },
    
    loadVehicles() {
        // This would normally come from server
        this.vehicles = [
            // Economy
            { model: 'dilettante', label: 'Dilettante', category: 'Economy', price: 150 },
            { model: 'issi2', label: 'ISSI', category: 'Economy', price: 160 },
            { model: 'panto', label: 'Panto', category: 'Economy', price: 140 },
            // Sedan
            { model: 'oracle', label: 'Oracle', category: 'Sedan', price: 250 },
            { model: 'fugitive', label: 'Fugitive', category: 'Sedan', price: 280 },
            { model: 'cognoscenti', label: 'Cognoscenti', category: 'Sedan', price: 350 },
            // SUV
            { model: 'cavalcade', label: 'Cavalcade', category: 'SUV', price: 400 },
            { model: 'granger', label: 'Granger', category: 'SUV', price: 380 },
            { model: 'baller', label: 'Baller', category: 'SUV', price: 450 },
            // Sports
            { model: 'jester', label: 'Jester', category: 'Sports', price: 500 },
            { model: 'comet2', label: 'Comet', category: 'Sports', price: 550 },
            { model: 'banshee', label: 'Banshee', category: 'Sports', price: 600 }
        ];
        
        this.renderVehicles(this.vehicles);
    },
    
    loadLocations() {
        // This would normally come from server
        this.locations = [
            { id: 'downtown', name: 'Downtown Car Rental', coords: '427.5, 318.2, 103.2' },
            { id: 'airport', name: 'Los Santos International Airport', coords: '-1008.5, -2718.8, 13.9' },
            { id: 'sandy', name: 'Sandy Shores Car Rental', coords: '1142.5, 2787.5, 52.3' }
        ];
        
        this.renderLocationsList();
    },
    
    renderVehicles(vehicles) {
        const vehiclesList = document.getElementById('vehiclesList');
        if (!vehiclesList) return;
        
        vehiclesList.innerHTML = '';
        
        if (vehicles.length === 0) {
            document.getElementById('noVehiclesMsg').style.display = 'block';
            return;
        }
        
        document.getElementById('noVehiclesMsg').style.display = 'none';
        
        vehicles.forEach(vehicle => {
            const card = document.createElement('div');
            card.className = 'vehicle-card';
            card.innerHTML = `
                <div class="icon"><i class="fas fa-car"></i></div>
                <div class="name">${vehicle.label}</div>
                <div class="category">${vehicle.category}</div>
                <div class="price">$${this.formatMoney(vehicle.price)}/day</div>
                <button class="btn-select" onclick="RentalUI.selectVehicle('${vehicle.model}', '${vehicle.label}', ${vehicle.price})">
                    <i class="fas fa-check"></i> Select
                </button>
            `;
            vehiclesList.appendChild(card);
        });
    },
    
    filterVehicles(searchTerm = null, category = null) {
        let filtered = this.vehicles;
        
        if (searchTerm) {
            filtered = filtered.filter(v => 
                v.label.toLowerCase().includes(searchTerm.toLowerCase())
            );
        }
        
        if (category && category !== '') {
            filtered = filtered.filter(v => v.category === category);
        }
        
        this.renderVehicles(filtered);
    },
    
    selectVehicle(model, label, price) {
        this.selectedVehicle = { model, label, price };
        
        document.getElementById('vehicleName').value = `${label} ($${this.formatMoney(price)}/day)`;
        document.getElementById('vehiclesSection').style.display = 'none';
        document.getElementById('formSection').style.display = 'block';
        
        this.renderDurationOptions();
        this.updateCostCalculation();
    },
    
    renderDurationOptions() {
        const durationGrid = document.getElementById('durationGrid');
        if (!durationGrid) return;
        
        durationGrid.innerHTML = '';
        
        const durations = [
            { days: 1, label: '1 Day', multiplier: 1.0 },
            { days: 3, label: '3 Days', multiplier: 0.85 },
            { days: 7, label: '1 Week', multiplier: 0.75 },
            { days: 14, label: '2 Weeks', multiplier: 0.65 },
            { days: 30, label: '1 Month', multiplier: 0.50 }
        ];
        
        durations.forEach(duration => {
            const cost = Math.floor(this.selectedVehicle.price * duration.days * duration.multiplier);
            const option = document.createElement('div');
            option.className = `duration-option ${duration.days === 1 ? 'selected' : ''}`;
            option.onclick = () => this.selectDuration(duration.days);
            option.innerHTML = `
                <div class="days">${duration.days}d</div>
                <div class="price">$${this.formatMoney(cost)}</div>
            `;
            durationGrid.appendChild(option);
        });
    },
    
    selectDuration(days) {
        this.selectedDays = days;
        document.querySelectorAll('.duration-option').forEach(opt => {
            opt.classList.remove('selected');
        });
        event.target.closest('.duration-option').classList.add('selected');
        this.updateCostCalculation();
    },
    
    updateCostCalculation() {
        if (!this.selectedVehicle) return;
        
        const days = this.selectedDays;
        const hasInsurance = document.getElementById('insuranceCheck')?.checked || false;
        
        // Get multiplier
        const durations = [
            { days: 1, multiplier: 1.0 },
            { days: 3, multiplier: 0.85 },
            { days: 7, multiplier: 0.75 },
            { days: 14, multiplier: 0.65 },
            { days: 30, multiplier: 0.50 }
        ];
        
        let multiplier = 1.0;
        for (let dur of durations) {
            if (dur.days === days) {
                multiplier = dur.multiplier;
                break;
            }
        }
        
        const basePrice = this.selectedVehicle.price;
        const baseCost = Math.floor(basePrice * days * multiplier);
        const discount = Math.floor(basePrice * days - baseCost);
        const insuranceCost = hasInsurance ? 50 : 0;
        const depositCost = 500;
        const totalCost = baseCost + insuranceCost + depositCost;
        
        // Update UI
        document.getElementById('durationDays').textContent = days;
        document.getElementById('baseCost').textContent = '$' + this.formatMoney(baseCost);
        document.getElementById('discountCost').textContent = '-$' + this.formatMoney(discount);
        
        const discountInfo = document.getElementById('discountInfo');
        if (discountInfo && multiplier < 1.0) {
            discountInfo.textContent = `(${Math.floor((1 - multiplier) * 100)}%)`;
        }
        
        document.getElementById('insuranceCost').textContent = '$' + this.formatMoney(insuranceCost);
        document.getElementById('depositCost').textContent = '$' + this.formatMoney(depositCost);
        document.getElementById('totalCost').textContent = '$' + this.formatMoney(totalCost);
    },
    
    submitRental(e) {
        e.preventDefault();
        
        if (!this.selectedVehicle) {
            this.showToast('Error', 'Please select a vehicle', 'error');
            return;
        }
        
        const hasInsurance = document.getElementById('insuranceCheck')?.checked || false;
        
        // Send to server (in production)
        console.log('Rental submitted:', {
            vehicle: this.selectedVehicle.model,
            days: this.selectedDays,
            insurance: hasInsurance
        });
        
        this.showToast('Success', 'Rental confirmed! Your vehicle is ready.', 'success');
        
        // Simulate rental success
        setTimeout(() => {
            this.showRentalStatus();
        }, 1500);
    },
    
    showRentalStatus() {
        document.getElementById('vehiclesSection').style.display = 'none';
        document.getElementById('formSection').style.display = 'none';
        document.getElementById('statusSection').style.display = 'block';
        
        document.getElementById('statusVehicle').textContent = this.selectedVehicle.label;
        document.getElementById('statusPlate').textContent = 'RENT-' + Math.random().toString(36).substr(2, 5).toUpperCase();
        document.getElementById('statusTime').textContent = `${this.selectedDays}d, 0h`;
        document.getElementById('statusCost').textContent = '$' + this.formatMoney(this.selectedVehicle.price);
    },
    
    confirmReturnVehicle() {
        if (!confirm('Are you sure you want to return this vehicle?')) return;
        
        this.showToast('Success', 'Vehicle returned successfully!', 'success');
        
        setTimeout(() => {
            this.goBack();
        }, 1500);
    },
    
    goBack() {
        document.getElementById('vehiclesSection').style.display = 'block';
        document.getElementById('formSection').style.display = 'none';
        document.getElementById('statusSection').style.display = 'none';
        document.getElementById('adminSection').style.display = 'none';
        
        document.getElementById('rentalForm').reset();
        this.selectedVehicle = null;
    },
    
    toggleAdmin() {
        if (this.isAdmin) {
            this.closeAdmin();
        } else {
            this.openAdmin();
        }
    },
    
    openAdmin() {
        this.isAdmin = true;
        document.getElementById('vehiclesSection').style.display = 'none';
        document.getElementById('formSection').style.display = 'none';
        document.getElementById('statusSection').style.display = 'none';
        document.getElementById('adminSection').style.display = 'block';
        
        this.renderLocationsList();
        this.renderVehiclesAdmin();
    },
    
    closeAdmin() {
        this.isAdmin = false;
        this.goBack();
    },
    
    switchAdminTab(btn) {
        // Remove active class from all buttons
        document.querySelectorAll('.admin-tab-btn').forEach(b => b.classList.remove('active'));
        // Add active to clicked button
        btn.classList.add('active');
        
        // Hide all tabs
        document.querySelectorAll('.admin-tab').forEach(tab => tab.style.display = 'none');
        
        // Show selected tab
        const tabName = btn.getAttribute('data-tab');
        const tab = document.getElementById(tabName + 'Tab');
        if (tab) tab.style.display = 'block';
    },
    
    renderLocationsList() {
        const list = document.getElementById('locationsList');
        if (!list) return;
        
        list.innerHTML = '';
        
        this.locations.forEach(location => {
            const item = document.createElement('div');
            item.className = 'location-item';
            item.innerHTML = `
                <div class="location-info">
                    <div class="location-name">${location.name}</div>
                    <div class="location-coords">${location.coords}</div>
                </div>
                <div class="location-actions">
                    <button class="btn btn-primary btn-sm" onclick="RentalUI.editLocation('${location.id}')">
                        <i class="fas fa-edit"></i> Edit
                    </button>
                    <button class="btn btn-danger btn-sm" onclick="RentalUI.deleteLocation('${location.id}')">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                </div>
            `;
            list.appendChild(item);
        });
    },
    
    renderVehiclesAdmin() {
        const list = document.getElementById('vehiclesListAdmin');
        if (!list) return;
        
        list.innerHTML = '';
        
        this.vehicles.forEach(vehicle => {
            const item = document.createElement('div');
            item.className = 'vehicle-item-admin';
            item.innerHTML = `
                <div class="vehicle-info-admin">
                    <div class="vehicle-name-admin">${vehicle.label}</div>
                    <div class="vehicle-price">$${this.formatMoney(vehicle.price)}/day - ${vehicle.category}</div>
                </div>
                <div class="vehicle-actions">
                    <button class="btn btn-primary btn-sm" onclick="RentalUI.editVehicle('${vehicle.model}')">
                        <i class="fas fa-edit"></i> Edit
                    </button>
                </div>
            `;
            list.appendChild(item);
        });
    },
    
    openAddLocationDialog() {
        this.showModal('Add New Location', `
            <form>
                <div class="form-group">
                    <label>Location Name</label>
                    <input type="text" id="locName" placeholder="e.g., Downtown Car Rental" required>
                </div>
                <div class="form-group">
                    <label>Coordinates (X, Y, Z)</label>
                    <input type="text" id="locCoords" placeholder="e.g., 427.5, 318.2, 103.2" required>
                </div>
                <div class="form-group">
                    <label>Heading</label>
                    <input type="number" id="locHeading" placeholder="e.g., 159.5" required>
                </div>
            </form>
        `, () => {
            const name = document.getElementById('locName').value;
            const coords = document.getElementById('locCoords').value;
            
            if (!name || !coords) {
                this.showToast('Error', 'Please fill all fields', 'error');
                return;
            }
            
            this.locations.push({
                id: 'location_' + Date.now(),
                name: name,
                coords: coords
            });
            
            this.renderLocationsList();
            this.showToast('Success', 'Location added successfully!', 'success');
            this.closeModal();
        });
    },
    
    openAddVehicleDialog() {
        this.showModal('Add New Vehicle', `
            <form>
                <div class="form-group">
                    <label>Vehicle Model</label>
                    <input type="text" id="vehModel" placeholder="e.g., dilettante" required>
                </div>
                <div class="form-group">
                    <label>Vehicle Label</label>
                    <input type="text" id="vehLabel" placeholder="e.g., Dilettante" required>
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select id="vehCategory" required>
                        <option>Economy</option>
                        <option>Sedan</option>
                        <option>SUV</option>
                        <option>Sports</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Price per Day</label>
                    <input type="number" id="vehPrice" placeholder="e.g., 150" required>
                </div>
            </form>
        `, () => {
            const model = document.getElementById('vehModel').value;
            const label = document.getElementById('vehLabel').value;
            const category = document.getElementById('vehCategory').value;
            const price = parseInt(document.getElementById('vehPrice').value);
            
            if (!model || !label || !price) {
                this.showToast('Error', 'Please fill all fields', 'error');
                return;
            }
            
            this.vehicles.push({
                model, label, category, price
            });
            
            this.renderVehicles(this.vehicles);
            this.renderVehiclesAdmin();
            this.showToast('Success', 'Vehicle added successfully!', 'success');
            this.closeModal();
        });
    },
    
    editLocation(id) {
        this.showToast('Info', 'Edit feature coming soon!', 'info');
    },
    
    deleteLocation(id) {
        if (!confirm('Are you sure?')) return;
        
        this.locations = this.locations.filter(l => l.id !== id);
        this.renderLocationsList();
        this.showToast('Success', 'Location deleted successfully!', 'success');
    },
    
    editVehicle(model) {
        this.showToast('Info', 'Edit feature coming soon!', 'info');
    },
    
    saveAdminSettings() {
        const insurance = document.getElementById('insurancePriceInput').value;
        const deposit = document.getElementById('damageDepositInput').value;
        const lateReturn = document.getElementById('lateReturnInput').value;
        
        console.log('Settings saved:', { insurance, deposit, lateReturn });
        this.showToast('Success', 'Settings saved successfully!', 'success');
    },
    
    showModal(title, content, callback) {
        this.modalCallback = callback;
        
        document.getElementById('modalTitle').textContent = title;
        document.getElementById('modalBody').innerHTML = content;
        document.getElementById('modalDialog').style.display = 'flex';
    },
    
    closeModal() {
        document.getElementById('modalDialog').style.display = 'none';
        this.modalCallback = null;
    },
    
    confirmModalAction() {
        if (this.modalCallback) {
            this.modalCallback();
        }
    },
    
    showToast(title, message, type = 'info') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        let icon = 'fa-info-circle';
        if (type === 'success') icon = 'fa-check-circle';
        if (type === 'error') icon = 'fa-exclamation-circle';
        if (type === 'warning') icon = 'fa-warning';
        
        toast.innerHTML = `
            <div class="toast-icon"><i class="fas ${icon}"></i></div>
            <div class="toast-content">
                <div class="toast-title">${title}</div>
                <div class="toast-message">${message}</div>
            </div>
        `;
        
        container.appendChild(toast);
        
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 300);
        }, 4000);
    },
    
    hideUI() {
        document.getElementById('rentalContainer').style.display = 'none';
    },
    
    formatMoney(amount) {
        return amount.toLocaleString('en-US');
    }
};

// ==================== INITIALIZATION ====================
document.addEventListener('DOMContentLoaded', () => {
    RentalUI.init();
});

// ==================== GLOBAL HELPERS ====================
function goBack() { RentalUI.goBack(); }
function returnVehicle() { RentalUI.showRentalStatus(); }
function confirmReturnVehicle() { RentalUI.confirmReturnVehicle(); }
function closeAdmin() { RentalUI.closeAdmin(); }
function closeModal() { RentalUI.closeModal(); }
function confirmModalAction() { RentalUI.confirmModalAction(); }
function openAddLocationDialog() { RentalUI.openAddLocationDialog(); }
function openAddVehicleDialog() { RentalUI.openAddVehicleDialog(); }
function saveAdminSettings() { RentalUI.saveAdminSettings(); }

// ==================== DEBUG ====================
console.log('%c[RENTAL-UI v2.1]%c Rental system interface loaded', 'color: #667eea; font-weight: bold;', 'color: #333;');
