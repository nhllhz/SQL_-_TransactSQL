select
	year(vc.fecha) as "Año"
	,sum(vd.cantidad) as "Ventas"
from
	vencab as vc
	inner join vendet as vd
	on vd.factura = vc.factura and vd.letra = vc.letra
where
	vc.anulada=0
	and vd.articulo = 'A102121071'
group by
	year(vc.fecha)