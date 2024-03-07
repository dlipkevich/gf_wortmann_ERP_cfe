﻿// #wortmann {
// #ТЗ_Счет_НаОплатуКлиенту
// добавление дополнительных реквизитов на форму	
// Галфинд Куканов 2022/07/15	
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)  
	
	ЭлементГруппаНовыхРеквизитов = Элементы.Добавить("ГруппаРеквизитыДоработок", Тип("ГруппаФормы"), Элементы.ГруппаДополнительно); 
	ЭлементГруппаНовыхРеквизитов.Вид = ВидГруппыФормы.ОбычнаяГруппа;  
	ЭлементГруппаНовыхРеквизитов.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная; 
	
	//элементы отображения новых реквизитов документа
	ЭлементСпецификацияПокупателя = Элементы.Добавить("СпецификацияПокупателя", Тип("ПолеФормы"), ЭлементГруппаНовыхРеквизитов); 
	ЭлементСпецификацияПокупателя.Заголовок = "Спецификация покупателя";   
	ЭлементСпецификацияПокупателя.Вид = ВидПоляФормы.ПолеВвода;
	ЭлементСпецификацияПокупателя.ПутьКДанным = "Объект.гф_СпецификацияПокупателя";
	ЭлементСпецификацияПокупателя.ТолькоПросмотр = Истина;

	
	ЭлементНомерПоставки = Элементы.Добавить("НомерПоставки", Тип("ПолеФормы"), ЭлементГруппаНовыхРеквизитов);
	ЭлементНомерПоставки.Заголовок = "Номер поставки";   
	ЭлементНомерПоставки.Вид = ВидПоляФормы.ПолеВвода;    
	ЭлементНомерПоставки.ПутьКДанным = "Объект.гф_НомерПоставки";
	ЭлементНомерПоставки.ТолькоПросмотр = Истина;
	
	гф_СоздатьТаблицуТоварыВКоробах();
	
КонецПроцедуры// } #wortmann

&НаСервере
Процедура гф_СоздатьТаблицуТоварыВКоробах()                                  	
	
	НовоеПолеСтраница = Элементы.Вставить("гф_СтраницаТоварыВКоробах", Тип("ГруппаФормы"),
	Элементы.ГруппаСтраницы, Элементы.ГруппаКомментарий); 
	НовоеПолеСтраница.Вид					= ВидГруппыФормы.Страница;	
	НовоеПолеСтраница.Видимость				= Истина;
	НовоеПолеСтраница.Заголовок				= "Товары в коробах";
	НовоеПолеСтраница.ПутьКДаннымЗаголовка	= "Объект.гф_ТоварыВКоробах.КоличествоСтрок";
	
	НовоеПолеТаблица = Элементы.Добавить("гф_ТаблицаТоварыВКоробах", Тип("ТаблицаФормы"), НовоеПолеСтраница);									
	НовоеПолеТаблица.ПутьКДанным = "Объект.гф_ТоварыВКоробах";
	НовоеПолеТаблица.Подвал = Истина;
	НовоеПолеТаблица.ТолькоПросмотр = Истина;
	
	//++ СадомцевСА 31.01.2024
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахЗаказКлиента", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок			= "Заказ клиента";
	НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным		= "Объект.гф_ТоварыВКоробах.ЗаказКлиента";
	//-- СадомцевСА 31.01.2024
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахВариантКомплектации", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок			= "Вариант комплектации";
	НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным		= "Объект.гф_ТоварыВКоробах.ВариантКомплектации";
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахВариантКомплектацииВладелец", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок			= "Номенклатура";
	НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
	// СадомцевСА 07.03.2024 тч гф_ТоварыВКоробах добавил реквизит Номенклатура
	//НовоеПоле.ПутьКДанным		= "Объект.гф_ТоварыВКоробах.ВариантКомплектации.Владелец";
	НовоеПоле.ПутьКДанным		= "Объект.гф_ТоварыВКоробах.Номенклатура";
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахКоличество", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок				= "Количество";
	НовоеПоле.Вид					= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным			= "Объект.гф_ТоварыВКоробах.Количество";
	НовоеПоле.ПутьКДаннымПодвала	= "Объект.гф_ТоварыВКоробах.ИтогКоличество";
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахЦена", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок				= "Цена";
	НовоеПоле.Вид					= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным			= "Объект.гф_ТоварыВКоробах.Цена"; 
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахВариантКомплектацииСтавкаНДС", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок			= "СтавкаНДС";
	НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным		= "Объект.гф_ТоварыВКоробах.СтавкаНДС";
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахСуммаНДС", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок				= "СуммаНДС";
	НовоеПоле.Вид					= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным			= "Объект.гф_ТоварыВКоробах.СуммаНДС";
	НовоеПоле.ПутьКДаннымПодвала	= "Объект.гф_ТоварыВКоробах.ИтогСуммаНДС";
	
	НовоеПоле = Элементы.Добавить("гф_ТоварыВКоробахСумма", Тип("ПолеФормы"), НовоеПолеТаблица);
	НовоеПоле.Заголовок				= "Сумма";
	НовоеПоле.Вид					= ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным			= "Объект.гф_ТоварыВКоробах.Сумма";
	НовоеПоле.ПутьКДаннымПодвала	= "Объект.гф_ТоварыВКоробах.ИтогСумма";	   
		
КонецПроцедуры 

