const courts = [
    { id: 5, name: 'Pickleball 01', typeId: 6, branchId: 6, status: 'Đang dùng' }
];

const courtTypes = {
    "7": { id: 7, sportId: 3, branchId: 6 }
};

let selectedBranchId = 0;
let selectedSportId = 0;

const filteredCourts = courts.filter(c => {
    const matchBranch = (selectedBranchId === 0 || c.branchId === selectedBranchId);
    const type = courtTypes[c.typeId];
    const matchSport = (selectedSportId === 0 || (type && type.sportId === selectedSportId));
    return matchBranch && matchSport;
});

console.log(filteredCourts.length);
