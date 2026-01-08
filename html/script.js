// ==================== STATE MANAGEMENT ====================
const RentalState = {
    selectedVehicle: null,
    selectedDays: 1,
    hasInsurance: false,
    activeRental: null
};

// ==================== INITIALIZATION ====================
document.addEventListener('DOMContentLoaded', function() {
    loadVehicles();
    setupEventListeners();
    console.log('[RENTAL-UI] Interface initialized');
});

// ==================== VEHICLE LOADING ====================
function loadVehicles() {
    const vehiclesList = document.getElementById('vehiclesList');
    vehiclesList.innerHTML = '';

    // Sample vehicles - in production, get from server
    const vehicles = [
        { model: 'dilettante', label: 'Dilettante', category: 'Economy', price: 150 },
        { model: 'issi2', label: 'ISSI', category: 'Economy', price: 160 },
        { model: 'oracle', label: 'Oracle', category: 'Sedan', price: 250 },
        { model: 'fugitive', label: 'Fugitive', category: 'Sedan', price: 280 },
        { model: 'cavalcade', label: 'Cavalcade', category: 'SUV', price: 400 },
        { model: 'jester', label: 'Jester', category: 'Sports', price: 500 },
    ];

    vehicles.forEach(vehicle => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        card.innerHTML = `
            <div class="icon"><i class="fas fa-car"></i></div>
            <div class="name">${vehicle.label}</div>
            <div class="category">${vehicle.category}</div>
            <div class="price">$${vehicle.price}/day</div>
            <button class="btn-select" onclick="selectVehicle('${vehicle.model}', '${vehicle.label}', ${vehicle.price})">
                Select
            </button>
        `;
        vehiclesList.appendChild(card);
    });
}

// ==================== VEHICLE SELECTION ====================
function selectVehicle(model, label, price) {
    RentalState.selectedVehicle = { model, label, price };
    
    document.getElementById('vehicleName').value = label + ' ($' + price + '/day)';
    document.getElementById('vehiclesSection').style.display = 'none';
    document.getElementById('formSection').style.display = 'block';
    
    updateCostCalculation();
}

// ==================== COST CALCULATION ====================
function updateCostCalculation() {
    if (!RentalState.selectedVehicle) return;

    const days = parseInt(document.getElementById('rentalDays').value);
    const hasInsurance = document.getElementById('insuranceCheck').checked;

    const baseCost = RentalState.selectedVehicle.price * days;
    const insuranceCost = hasInsurance ? 50 : 0;
    const totalCost = baseCost + insuranceCost;

    document.getElementById('baseCost').textContent = '$' + formatMoney(baseCost);
    document.getElementById('insuranceCost').textContent = '$' + formatMoney(insuranceCost);
    document.getElementById('totalCost').textContent = '$' + formatMoney(totalCost);
}

// ==================== FORM SUBMISSION ====================
document.getElementById('rentalForm')?.addEventListener('submit', function(e) {
    e.preventDefault();

    const vehicle = RentalState.selectedVehicle;
    const days = parseInt(document.getElementById('rentalDays').value);
    const hasInsurance = document.getElementById('insuranceCheck').checked;

    if (!vehicle) {
        showAlert('Please select a vehicle', 'error');
        return;
    }

    // Send to server
    fetch(`https://${GetParentResourceName()}/rental:requestRent`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            vehicle: vehicle.model,
            days: days,
            insurance: hasInsurance
        })
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              showAlert('Rental successful!', 'success');
              goBack();
          } else {
              showAlert(data.message || 'Rental failed', 'error');
          }
      });
});

// ==================== EVENT LISTENERS ====================
function setupEventListeners() {
    // Update cost when duration changes
    document.getElementById('rentalDays')?.addEventListener('change', updateCostCalculation);

    // Update cost when insurance changes
    document.getElementById('insuranceCheck')?.addEventListener('change', updateCostCalculation);
}

// ==================== NAVIGATION ====================
function goBack() {
    document.getElementById('formSection').style.display = 'none';
    document.getElementById('vehiclesSection').style.display = 'block';
    document.getElementById('statusSection').style.display = 'none';
    
    // Reset form
    document.getElementById('rentalForm').reset();
    RentalState.selectedVehicle = null;
}

// ==================== RETURN VEHICLE ====================
function returnVehicle() {
    if (!confirm('Are you sure you want to return this vehicle?')) {
        return;
    }

    fetch(`https://${GetParentResourceName()}/rental:requestReturn`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({})
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              showAlert('Vehicle returned successfully', 'success');
              goBack();
          } else {
              showAlert(data.message || 'Return failed', 'error');
          }
      });
}

// ==================== UTILITY FUNCTIONS ====================
function formatMoney(amount) {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount).replace('$', '');
}

function showAlert(message, type = 'info') {
    const alertClass = type === 'success' ? 'text-success' : type === 'error' ? 'text-danger' : 'text-info';
    
    // Create alert element
    const alert = document.createElement('div');
    alert.className = `alert alert-${type} ${alertClass}`;
    alert.textContent = message;
    alert.style.cssText = `
        padding: 15px;
        margin: 10px 0;
        border-radius: 5px;
        background: ${type === 'success' ? '#d4edda' : type === 'error' ? '#f8d7da' : '#d1ecf1'};
        border: 1px solid ${type === 'success' ? '#c3e6cb' : type === 'error' ? '#f5c6cb' : '#bee5eb'};
    `;

    const container = document.querySelector('.rental-content');
    if (container) {
        container.insertBefore(alert, container.firstChild);
        setTimeout(() => alert.remove(), 3000);
    }
}

// ==================== NUI COMMUNICATION ====================
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'showRentalUI') {
        document.querySelector('.rental-container').style.display = 'block';
    } else if (data.type === 'hideRentalUI') {
        document.querySelector('.rental-container').style.display = 'none';
    } else if (data.type === 'updateStatus') {
        updateRentalStatus(data.status);
    } else if (data.type === 'notification') {
        showAlert(data.message, data.level);
    }
});

function updateRentalStatus(status) {
    if (!status) {
        document.getElementById('statusSection').style.display = 'none';
        return;
    }

    document.getElementById('statusVehicle').textContent = status.vehicle;
    document.getElementById('statusPlate').textContent = status.plate;
    document.getElementById('statusTime').textContent = `${status.daysRemaining}d ${status.hoursRemaining}h`;
    document.getElementById('statusCost').textContent = '$' + status.dailyCost;

    document.getElementById('vehiclesSection').style.display = 'none';
    document.getElementById('formSection').style.display = 'none';
    document.getElementById('statusSection').style.display = 'block';
}

// ==================== DEBUG ====================
console.log('[RENTAL-UI] Rental interface loaded');
