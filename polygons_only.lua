local polygon_tags = osm2pgsql.define_area_table('planet_osm_polygon', {
    { column = 'osm_id', type = 'int8' },
    { column = 'name', type = 'text' },
    { column = 'admin_level', type = 'text' },
    { column = 'boundary', type = 'text' },
    { column = 'landuse', type = 'text' },
    { column = 'natural', type = 'text' },
    { column = 'building', type = 'text' },
    { column = 'leisure', type = 'text' },
    { column = 'amenity', type = 'text' },
    { column = 'tags', type = 'hstore' },
    { column = 'way', type = 'geometry', projection = 4326 },
})

function osm2pgsql.process_way(object)
    -- Only process closed ways that should be areas
    if object.is_closed and (object.tags.landuse or object.tags.building or 
                            object.tags.natural or object.tags.leisure or 
                            object.tags.amenity or object.tags.boundary) then
        local tags = {}
        for k, v in pairs(object.tags) do
            tags[k] = v
        end
        
        polygon_tags:insert({
            osm_id = object.id,
            name = object.tags.name,
            admin_level = object.tags.admin_level,
            boundary = object.tags.boundary,
            landuse = object.tags.landuse,
            natural = object.tags.natural,
            building = object.tags.building,
            leisure = object.tags.leisure,
            amenity = object.tags.amenity,
            tags = tags,
            way = object:as_area()
        })
    end
end

function osm2pgsql.process_relation(object)
    -- Process multipolygon and boundary relations
    if object.tags.type == 'multipolygon' or object.tags.type == 'boundary' then
        local tags = {}
        for k, v in pairs(object.tags) do
            tags[k] = v
        end
        
        polygon_tags:insert({
            osm_id = -object.id,  -- Negative for relations
            name = object.tags.name,
            admin_level = object.tags.admin_level,
            boundary = object.tags.boundary,
            landuse = object.tags.landuse,
            natural = object.tags.natural,
            building = object.tags.building,
            leisure = object.tags.leisure,
            amenity = object.tags.amenity,
            tags = tags,
            way = object:as_area()
        })
    end
end
