
export const useGeo = () => {
  const getDepartments = async () => {
    return await $fetch('https://geo.api.gouv.fr/departements')
  }

  const getCommunesByDepartment = async (code: string) => {
    return await $fetch(`https://geo.api.gouv.fr/departements/${code}/communes?geometry=contour&format=geojson`)
  }

  return {
    getDepartments,
    getCommunesByDepartment
  }
}
