﻿
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)                  
	
	
	НовоеПолеСтраница = Элементы.Вставить("гф_СтраницаB2B", Тип("ГруппаФормы"),
										Элементы.СтраницыКарточкаНоменклатуры);
	НовоеПолеСтраница.Вид = ВидГруппыФормы.Страница;	
	НовоеПолеСтраница.Видимость = Истина;
	НовоеПолеСтраница.Заголовок = "B2B дополнительные реквизиты";
	//НовоеПолеСтраница.ПутьКДаннымЗаголовка = "Объект.гф_ТоварыВКоробах.КоличествоСтрок";
	
	НовоеПоле = Элементы.Добавить("B2B_Портал", Тип("ПолеФормы"), НовоеПолеСтраница);
	НовоеПоле.Заголовок = "B2B_Портал";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.B2B_Портал";   
	
	НовоеПоле = Элементы.Добавить("B2B_НазваниеWeb", Тип("ПолеФормы"), НовоеПолеСтраница);
	НовоеПоле.Заголовок = "B2B_НазваниеWeb";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.B2B_НазваниеWeb";   

	
	НовоеПоле = Элементы.Добавить("B2B_ГруппаНаСайтеОсновная", Тип("ПолеФормы"), НовоеПолеСтраница);
	НовоеПоле.Заголовок = "Группа на сайте (основная)";
	НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
	НовоеПоле.ПутьКДанным = "Объект.B2B_ГруппаНаСайтеОсновная";
	//НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ТоварыВКоробахВариантКомплектацииПриИзменении");
	
	НовоеПоле = Элементы.Добавить("B2B_ГруппыНаСайте", Тип("ТаблицаФормы"), НовоеПолеСтраница);
	НовоеПоле.Заголовок = "Группы на сайте";
	НовоеПоле.ПутьКДанным = "Объект.B2B_ГруппыНаСайте";   
	НовоеПоле.Видимость					= Истина;
	НовоеПоле.Отображение				= ОтображениеТаблицы.Список; 
	НовоеПоле.ПоложениеЗаголовка		= ПоложениеЗаголовкаЭлементаФормы.Лево;
	НовоеПоле.КоманднаяПанель.Видимость = Ложь;
	НовоеПоле.ВариантУправленияВысотой	= ВариантУправленияВысотойТаблицы.ПоСодержимому; 
	
	НовоеПоле = Элементы.Добавить("B2B_ГруппыНаСайте_Группа", Тип("ПолеФормы"), Элементы.B2B_ГруппыНаСайте);
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.B2B_ГруппыНаСайте.Группа";
	
	// ++ СадомцевСА 18.10.2023 Добавил кнопку Перейти - Варианты комплектации
	// при условии что функциональная опция "Использовать сборку зарборку" ВЫКЛЮЧЕНА
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee6d0442ba9c05 (п.1)
	ИспользоватьСборкуРазборку = ПолучитьФункциональнуюОпцию("ИспользоватьСборкуРазборку");
	Если НЕ ИспользоватьСборкуРазборку Тогда
		//Создаем Команду
		НоваяКоманда = ЭтаФорма.Команды.Добавить("гф_ПерейтиВариантыКомплектации");
		НоваяКоманда.Действие = "гф_ВыполнитьПерейтиВариантыКомплектации";//Имя процедуры
		НоваяКоманда.Заголовок = "Варианты комплектации";
		//Создаем Кнопку
		НоваяКнопка = ЭтаФорма.Элементы.Вставить("гф_КнопкаПерейтиВариантыКомплектации", Тип("КнопкаФормы"), Элементы.ГруппаКнопокПроизводство);
		НоваяКнопка.ИмяКоманды = "гф_ПерейтиВариантыКомплектации";
	КонецЕсли;
	// -- СадомцевСА 18.10.2023
	
	// ++ Галфинд_ДомнышеваКР_04_03_2024
	ТипПолеФормы = Тип("ПолеФормы");

	НовыйЭлемент  = Элементы.Добавить("гф_ШтукВУпаковке", ТипПолеФормы, Элементы.СворачиваемаяГруппаЕдиницыИзмерения);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ШтукВУпаковке";
	// -- Галфинд_ДомнышеваКР_04_03_2024

КонецПроцедуры

&НаКлиенте
Процедура гф_ВыполнитьПерейтиВариантыКомплектации(Команда)
	ГиперссылкаПерейтиСформироватьПараметрыИВопрос("ГиперссылкаПерейтиВариантыКомплектации", "");
КонецПроцедуры  
