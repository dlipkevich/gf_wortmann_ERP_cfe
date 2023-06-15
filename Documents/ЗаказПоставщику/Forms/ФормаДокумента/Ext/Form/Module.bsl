﻿
#Область ОбработчикиСобытийФормы
	
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)

	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8127bcee7bda45d711ed77ea01e7705f
	// Создание элементов формы
	// Галфинд Sakovich 2022/12/11
	гф_СоздатьНовыеРеквизиты();
	гф_УстановитьВидимостьИДоступность();
	// } #wortmann
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ПриОткрытииПосле(Отказ)
	гф_ОбновитьЗаголовокСтраницыПродукцияВКоробах();
	// ++ Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	гф_ОбновитьЗаголовокСтраницыIDКоробов();
	// ++ Галфинд_ДомнышеваКР_07_06_2023
КонецПроцедуры

&НаКлиенте
Процедура гф_ПродукцияВКоробахПриИзменении(Элемент) 
	гф_ОбновитьЗаголовокСтраницыПродукцияВКоробах();
КонецПроцедуры

&НаКлиенте
Процедура гф_ПродукцияВКоробахIDКоробаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка) 

	СтандартнаяОбработка = Ложь;
	
	ТекущиеДанные = Элементы.гф_ПродукцияВКоробах.ТекущиеДанные;
	
	ПараметрыФормы = Новый Структура;
	
	ПараметрыОтбора = Новый Структура;
	ПараметрыОтбора.Вставить("гф_Организация",Объект.Организация);
	ПараметрыОтбора.Вставить("гф_Поставка",ПредопределенноеЗначение("Документ.ПриобретениеТоваровУслуг.ПустаяСсылка"));
		
	Если ЗначениеЗаполнено(ТекущиеДанные.ВариантКомплектации) Тогда
		 ПараметрыОтбора.Вставить("гф_Комплектация", ТекущиеДанные.ВариантКомплектации);
	КонецЕсли;
	 
	ПараметрыФормы.Вставить("Отбор", ПараметрыОтбора);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("гф_ОбработкаВыбораИДКороба", ЭтотОбъект);
	
	ОткрытьФорму("Документ.УпаковочныйЛист.ФормаВыбора", ПараметрыФормы, ЭтотОбъект, , , , ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура гф_IDКоробовПриИзменении(Элемент) 
	
	гф_ОбновитьЗаголовокСтраницыIDКоробов();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура гф_ОбработатьУпаковочныеЛисты(Команда)
	ОбработатьУпаковочныеЛистыНаСервере();
КонецПроцедуры 

&НаКлиенте
Процедура ПечатьКодыМаркировки(ИмяКоманды)
    // ++Галфинд_ДомнышеваКР_15_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee0a1be12f8135
	Если Объект.гф_IDКоробов.Количество() = 0 Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю("Не заполнены данные Упаковочных Листов в IDКоробов!");
		Возврат;
	КонецЕсли;
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("ЗаказПоставщику", Объект.Ссылка);
	
	ОткрытьФорму("Документ.ЗаказПоставщику.Форма.гф_ФормаПечатиЭтикеток", ДопПараметры, ЭтотОбъект);
	Модифицированность = Ложь;
	// --Галфинд_ДомнышеваКР_15_06_2023
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
			
	ТипПолеФормы = Тип("ПолеФормы");
	ТипТаблицаФормы = Тип("ТаблицаФормы");
	ТипКнопкаФормы = Тип("КнопкаФормы");
	ТипГруппаФормы = Тип("ГруппаФормы");
	
	// тч "Товары в коробах"
	НовыйЭлемент = Элементы.Вставить("гф_ГруппаПродукцияВКоробах", ТипГруппаФормы,
		Элементы.ГруппаСтраницы, Элементы.СтраницаДоставка);
    НовыйЭлемент.Вид = ВидГруппыФормы.Страница;
	НовыйЭлемент.Заголовок = "Товары в коробах";
	//НовыйЭлемент.ПутьКДаннымЗаголовка = "Объект.гф_ПродукцияВКоробах.КоличествоСтрок";

	
	НовыйЭлемент = Элементы.Вставить("гф_ПродукцияВКоробах", ТипТаблицаФормы,
		Элементы.гф_ГруппаПродукцияВКоробах);
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах"; 
	НовыйЭлемент.УстановитьДействие("ПриИзменении", "гф_ПродукцияВКоробахПриИзменении");
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахНомерСтроки", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.НомерСтроки";
	НовыйЭлемент.Заголовок = " N ";
	// ++Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	//НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахIDКороба", ТипПолеФормы,
	//	Элементы.гф_ПродукцияВКоробах);
	//НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
	//НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.IDКороба"; 
	//НовыйЭлемент.Заголовок = "IDКороба";
	//НовыйЭлемент.УстановитьДействие("НачалоВыбора","гф_ПродукцияВКоробахIDКоробаНачалоВыбора");
	// --Галфинд_ДомнышеваКР_07_06_2023
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахВариантКомплектации", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.ВариантКомплектации"; 
	НовыйЭлемент.Заголовок = "Артикул с ростовкой (вариант комплектации)";
    	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахКоличествоКоробов", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.КоличествоКоробов"; 
	НовыйЭлемент.Заголовок = "Количество коробов";
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахСтоимостьКороба", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.СтоимостьКороба"; 
	НовыйЭлемент.Заголовок = "Стоимость короба";
	
	// vvv Галфинд \ Sakovich 08.02.2023
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахНДС", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.НДС"; 
	НовыйЭлемент.Заголовок = "НДС";
	
	НовыйЭлемент = Элементы.Вставить("ПродукцияВКоробахСумма", ТипПолеФормы,
		Элементы.гф_ПродукцияВКоробах);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_ПродукцияВКоробах.Сумма"; 
	НовыйЭлемент.Заголовок = "Сумма";
	// ^^^ Галфинд \ Sakovich 08.02.2023 
	
	// Эмиссия КМ
	НовыйЭлемент = Элементы.Вставить("гф_ГруппаЭмиссияКМ", ТипГруппаФормы,
		Элементы.ГруппаОсновное, Элементы.ГруппаШапка);
	НовыйЭлемент.Вид = ВидГруппыФормы.ОбычнаяГруппа;
	НовыйЭлемент.Группировка = ГруппировкаПодчиненныхЭлементовФормы.ГоризонтальнаяЕслиВозможно;
	НовыйЭлемент.ЦветФона = WebЦвета.Перламутровый;
	НовыйЭлемент.ОтображатьЗаголовок = Ложь;
	
	НовыйЭлемент = Элементы.Вставить("гф_ЗаказатьКМ", ТипПолеФормы,
	Элементы.гф_ГруппаЭмиссияКМ);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ЗаказатьКМ"; 
	НовыйЭлемент.Заголовок = "Заказать КМ";

	НовыйЭлемент = Элементы.Вставить("гф_КМЭмитированы", ТипПолеФормы,
	Элементы.гф_ГруппаЭмиссияКМ);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
	НовыйЭлемент.ПутьКДанным = "Объект.гф_КМЭмитированы"; 
	НовыйЭлемент.Заголовок = "КМ эмитированы";
	НовыйЭлемент.ТолькоПросмотр = Истина;
	
	// Действия
	НоваяКоманда = Команды.Добавить("гф_ОбработатьУпаковочныеЛисты");
	// ++Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	//НоваяКоманда.Заголовок = "Обработать упаковочные листы"; 
	НоваяКоманда.Заголовок = "Агрегировать короба";
	// --Галфинд_ДомнышеваКР_07_06_2023
	НоваяКоманда.Подсказка = "Создать и заполнить упаковочные листы в строках";
	НоваяКоманда.Действие = "гф_ОбработатьУпаковочныеЛисты";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина;
	
	НоваяКнопка = Элементы.Вставить("гф_ОбработатьУпаковочныеЛисты",
		ТипКнопкаФормы, Элементы.гф_ПродукцияВКоробах.КоманднаяПанель);
	// ++Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	//НоваяКнопка.Заголовок = "Обработать упаковочные листы";
	НоваяКнопка.Заголовок = "Агрегировать короба";
	// --Галфинд_ДомнышеваКР_07_06_2023
	НоваяКнопка.ИмяКоманды = "гф_ОбработатьУпаковочныеЛисты";
	
	НоваяКоманда = Команды.Добавить("гф_ПересчитатьТовары");
	НоваяКоманда.Заголовок = "Пересчитать товары (по коробам)";
	НоваяКоманда.Действие = "гф_ПересчитатьТовары";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина;
	
	НоваяКнопка = Элементы.Добавить("гф_ПересчитатьТовары", ТипКнопкаФормы, 
		Элементы.ГруппаТоварыЗаполнить);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ПересчитатьТовары";
	
	// ++ Галфинд_ДомнышеваКР_02_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	// тч "ID коробов"
	НовыйЭлемент = Элементы.Вставить("гф_ГруппаIDКоробов", ТипГруппаФормы,
		Элементы.ГруппаСтраницы, Элементы.СтраницаДоставка);
    НовыйЭлемент.Вид = ВидГруппыФормы.Страница;
	НовыйЭлемент.Заголовок = "ID коробов";
	
	НовыйЭлемент = Элементы.Вставить("гф_IDКоробов", ТипТаблицаФормы,
		Элементы.гф_ГруппаIDКоробов);
    НовыйЭлемент.ПутьКДанным = "Объект.гф_IDКоробов"; 
	НовыйЭлемент.УстановитьДействие("ПриИзменении", "гф_IDКоробовПриИзменении");
	
	НовыйЭлемент = Элементы.Вставить("IDКоробовНомерСтроки", ТипПолеФормы,
		Элементы.гф_IDКоробов);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_IDКоробов.НомерСтроки";
	НовыйЭлемент.Заголовок = " N ";
	
	НовыйЭлемент = Элементы.Вставить("IDКоробовIDКороба", ТипПолеФормы,
		Элементы.гф_IDКоробов);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
	НовыйЭлемент.ПутьКДанным = "Объект.гф_IDКоробов.IDКороба"; 
	НовыйЭлемент.Заголовок = "ID Короба";
	НовыйЭлемент.УстановитьДействие("НачалоВыбора","гф_ПродукцияВКоробахIDКоробаНачалоВыбора");
	
	НовыйЭлемент = Элементы.Вставить("IDКоробовВариантКомплектации", ТипПолеФормы,
		Элементы.гф_IDКоробов);
    НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
    НовыйЭлемент.ПутьКДанным = "Объект.гф_IDКоробов.ВариантКомплектации"; 
	НовыйЭлемент.Заголовок = "Артикул с ростовкой (вариант комплектации)";
		
	НоваяКоманда = Команды.Добавить("гф_ПечатьКодыМаркировки");
	НоваяКоманда.Заголовок = "Печать этикеток";
	НоваяКоманда.Подсказка = "Выводит на печать КМ по всем Ул указанным в IDКоробов";
	НоваяКоманда.Действие = "ПечатьКодыМаркировки";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина; 
	
	НоваяКнопка = Элементы.Добавить("гф_ПечатьКодыМаркировки", ТипКнопкаФормы, 
		Элементы.ПодменюПечать);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ПечатьКодыМаркировки";
	
	НоваяКоманда = Команды.Добавить("гф_ПечатьКодыМаркировкиПредварительнымПросмотром");
	НоваяКоманда.Заголовок = "Печать этикеток (пред. просмотр)";
	НоваяКоманда.Подсказка = "Выводит на печать КМ по всем Ул указанным в IDКоробов";
	НоваяКоманда.Действие = "ПечатьКодыМаркировки";
	НоваяКоманда.ИзменяетСохраняемыеДанные = Истина; 	
	
	НоваяКнопка = Элементы.Добавить("гф_ПечатьКодыМаркировкиПредварительнымПросмотром", ТипКнопкаФормы, 
		Элементы.ПодменюПечать);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ПечатьКодыМаркировкиПредварительнымПросмотром";
	//-- Галфинд_ДомнышеваКР_02_06_2023

КонецПроцедуры	

&НаСервере
Процедура гф_УстановитьВидимостьИДоступность()
	
	Если ЗначениеЗаполнено(Объект.Склад) Тогда 
		ВидимостьСтраницыТоварыВКоробах();
	Иначе
		Элементы.гф_ГруппаПродукцияВКоробах.Видимость = Ложь;
	КонецЕсли;
	
	гф_ДоступностьЭлементовГруппыЭмиссияКМ();
	
КонецПроцедуры

&НаСервере
Процедура ВидимостьСтраницыТоварыВКоробах() 
		
	ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Товары в коробах"); 
	
	ТоварыВКоробахЗначение = УправлениеСвойствами.ЗначениеСвойства(Объект.Склад, ТоварыВКоробах);	
	
	Если ЗначениеЗаполнено(ТоварыВКоробахЗначение) И ТоварыВКоробахЗначение = Истина Тогда
		 Элементы.гф_ГруппаПродукцияВКоробах.Видимость = Истина; 
	Иначе
		 Элементы.гф_ГруппаПродукцияВКоробах.Видимость = Ложь;
		 Объект.гф_ПродукцияВКоробах.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура гф_ДоступностьЭлементовГруппыЭмиссияКМ()

	ДоступностьГруппыЭмиссияКМ = Не Объект.гф_КМЭмитированы;
	Элементы.гф_ГруппаЭмиссияКМ.Доступность = ДоступностьГруппыЭмиссияКМ;
	Если Не ДоступностьГруппыЭмиссияКМ Тогда
		Возврат;
	КонецЕсли;
	ЕстьМаркируемаяПродукция = гф_ОпределитьНаличиеМаркируемойПродукции();
	Элементы.гф_ГруппаЭмиссияКМ.Доступность = ЕстьМаркируемаяПродукция;
    Элементы.гф_ОбработатьУпаковочныеЛисты.Доступность = Объект.гф_КМЭмитированы; // Галфинд_ДомнышеваКР_07_06_2023
КонецПроцедуры

&НаСервере
Функция гф_ОпределитьНаличиеМаркируемойПродукции() Экспорт
	
	тзТовары = Объект.Товары.Выгрузить();	
	ЕстьМаркируемаяПродукция = Документы.ПриобретениеТоваровУслуг.гф_ОпределитьНаличиеМаркируемойПродукции(тзТовары);
	Возврат ЕстьМаркируемаяПродукция;
	
КонецФункции

&НаКлиенте
Процедура гф_ОбновитьЗаголовокСтраницыПродукцияВКоробах()
	
	ИтогДляВывода = Объект["гф_ПродукцияВКоробах"].Итог("КоличествоКоробов");
	КоличествоСтрок = Объект["гф_ПродукцияВКоробах"].Количество();
	
	Элементы["гф_ГруппаПродукцияВКоробах"].Заголовок = 
	?(КоличествоСтрок = 0, 
	// ++ Галфинд_ДомнышеваКР_07_06_2023
	//"Продукция в коробах",
	//"Продукция в коробах (коробов: " + ИтогДляВывода + ") (вариантов: "+ Объект["гф_ПродукцияВКоробах"].Количество() + ")");
	"Товары в коробах",
	"Товары в коробах ( "+ КоличествоСтрок + ")");
	// -- Галфинд_ДомнышеваКР_07_06_2023
КонецПроцедуры

&НаСервере
Функция ЗначениеРеквизитаОбъекта(Объект,ИмяРеквизита)
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект,ИмяРеквизита);	
КонецФункции

&НаКлиенте
Процедура гф_ОбработкаВыбораИДКороба(ВыбранноеЗначение, ДополнительныеПараметры) Экспорт
	
	Если ВыбранноеЗначение <> Неопределено Тогда
		Элементы.гф_ПродукцияВКоробах.ТекущиеДанные.IDКороба = ВыбранноеЗначение;
		Элементы.гф_ПродукцияВКоробах.ТекущиеДанные.ВариантКомплектации = 
										ЗначениеРеквизитаОбъекта(ВыбранноеЗначение,"гф_Комплектация");
		Элементы.гф_ПродукцияВКоробах.ТекущиеДанные.КоличествоКоробов = 1;
	КонецЕсли;	
	
КонецПроцедуры	

&НаКлиенте
Процедура гф_ПослеПересчетаТоваров()
	
	Для каждого Строка Из Объект.Товары Цикл 
		КэшСтроки = Новый Структура("Цена, СуммаСНДС, СуммаНДС, Сумма, Назначение", 
		Строка["Цена"], Строка["СуммаСНДС"], Строка["СуммаНДС"], Строка["Сумма"], Строка["Назначение"]);
		Элементы.Товары.ТекущаяСтрока = Строка.ПолучитьИдентификатор();
		ТоварыНоменклатураПриИзменении(Элементы.ТоварыНоменклатура);
		ЗаполнитьЗначенияСвойств(Строка, КэшСтроки);
	КонецЦикла;
	СуммаЗаказанныхСтрок = ПолучитьСуммуДокументаНаСервере();
	Объект.СуммаДокумента = СуммаЗаказанныхСтрок;
	СуммаЗаказаноСЗалоговойТарой = СуммаЗаказанныхСтрок;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСуммуДокументаНаСервере()
	докОбъект = РеквизитФормыВЗначение("Объект");
	СуммаЗаказанныхСтрок = докОбъект.ПолучитьСуммуЗаказанныхСтрок();
	Возврат СуммаЗаказанныхСтрок;
КонецФункции


&НаКлиенте
Процедура гф_ПересчитатьТовары(Команда)
	
	Если Объект.Товары.Количество() > 0 Тогда
		ТекстВопроса = НСтр("ru='Табличная часть ""Товары"" будет очищена. Продолжить?'");
		ДопПараметры = Новый Структура() ;
		Оповещение = Новый ОписаниеОповещения("гф_ВопросПересчитатьТоварыЗавершение", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	Иначе
		гф_ОбработатьТоврыПриЗагрузкеИзФайла();
		гф_ПослеПересчетаТоваров();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ВопросПересчитатьТоварыЗавершение (Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		Объект.Товары.Очистить();
		гф_ОбработатьТоврыПриЗагрузкеИзФайла();
		гф_ПослеПересчетаТоваров();
	КонецЕсли;

КонецПроцедуры	

&НаСервере
Процедура гф_ОбработатьТоврыПриЗагрузкеИзФайла()
	
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.гф_ПересчитатьТЧТоварыНаОсновнииКоробов();
	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект"); 
			
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьУпаковочныеЛистыНаСервере()
	
	тзПродукцияВКоробах = Объект.гф_ПродукцияВКоробах.Выгрузить();
	// ++ Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	тзIDКоробов =  Объект.гф_IDКоробов.Выгрузить(); 
    // -- Галфинд_ДомнышеваКР_07_06_2023
	мСтрокДляСозданияУпЛистов = Новый Массив;
	мСтрокДляРазмножения = Новый Массив;
	Для каждого стрТз Из тзПродукцияВКоробах Цикл
		// ++ Галфинд_ДомнышеваКР_07_06_2023
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
		
		//Если ЗначениеЗаполнено(стрТз["ВариантКомплектации"]) И стрТз["КоличествоКоробов"] > 1 Тогда
		//	мСтрокДляРазмножения.Добавить(стрТз);
		//КонецЕсли;
		Если ЗначениеЗаполнено(стрТз["ВариантКомплектации"]) И ЗначениеЗаполнено(стрТз["КоличествоКоробов"]) Тогда
			Если тзIDКоробов.Количество()>0 И 
				УпаковочныеЛистыСозданыВсе(стрТз["ВариантКомплектации"], стрТз["КоличествоКоробов"]) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю("По всем вариантам комплектации короба сагрегированы.");
			Иначе
				мСтрокДляРазмножения.Добавить(стрТз);
			КонецЕсли;
		КонецЕсли;
        // -- Галфинд_ДомнышеваКР_07_06_2023
	КонецЦикла;
	
	Для каждого Эл Из мСтрокДляРазмножения Цикл
		Для Сч = 1 По Эл["КоличествоКоробов"] Цикл
			// ++ Галфинд_ДомнышеваКР_07_06_2023
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
			//нс = тзПродукцияВКоробах.Вставить(тзПродукцияВКоробах.Индекс(Эл));
			нс = тзIDКоробов.Вставить(тзПродукцияВКоробах.Индекс(Эл));
            // -- Галфинд_ДомнышеваКР_07_06_2023
			ЗаполнитьЗначенияСвойств(нс, Эл);
			//нс["КоличествоКоробов"] = 1; // Галфинд_ДомнышеваКР_07_06_2023
			Если Сч > 1 Тогда
				нс["IDКороба"] = "";
			КонецЕсли;
		КонецЦикла;
		//тзПродукцияВКоробах.Удалить(Эл); // Галфинд_ДомнышеваКР_07_06_2023
	КонецЦикла;
	// ++ Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	//Для каждого стрТз Из тзПродукцияВКоробах Цикл
	Для каждого стрТз Из тзIDКоробов Цикл 
	// -- Галфинд_ДомнышеваКР_07_06_2023	
		Если Не ЗначениеЗаполнено(стрТз["IDКороба"]) Тогда
			мСтрокДляСозданияУпЛистов.Добавить(стрТз);
		КонецЕсли;
	КонецЦикла;
	
	ОшибкаПодбораСерийногоНомера = Ложь;
	мЗадействованныхСерийныхНомеров = Новый Массив;
	ОрганизацияУпЛиста = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Ссылка, "Организация");
	СлужебноеНазначение = Справочники.Назначения.гф_Техническое;
	
	Для каждого строкаУпЛист Из мСтрокДляСозданияУпЛистов Цикл
		
		РезультатЗапроса = ПолучитьСвободныеСерийныеНомера();
		
		Если РезультатЗапроса.Пустой() Тогда
			ОбщегоНазначения.СообщитьПользователю("Не найден свободный Серийный номер для создания УпаковочногоЛиста");
			ОшибкаПодбораСерийногоНомера = Истина;
			Продолжить;
		КонецЕсли;
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		мЗадействованныхСерийныхНомеров.Добавить(Выборка["Наименование"]);
		МенеджерЗаписи = РегистрыСведений.гф_ЗагруженныеСерийныеНомера.СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Наименование = Выборка["Наименование"];
		МенеджерЗаписи.Прочитать();
		Если МенеджерЗаписи.Выбран() Тогда
			МенеджерЗаписи.Использован = Истина;
			МенеджерЗаписи.Записать();
		КонецЕсли;
		
		ДокУпЛист = Документы.УпаковочныйЛист.СоздатьДокумент();
		ДокУпЛист.Дата = ТекущаяДатаСеанса();
		ДокУпЛист.Код = Выборка["Наименование"];
		ДокУпЛист.Вид = Перечисления.ВидыУпаковочныхЛистов.Входящий;
		ДокУпЛист.гф_СостояниеКороба = Справочники.гф_СостянияКоробов.ПолныйКомплект;
		ДокУпЛист.гф_Комплектация = строкаУпЛист.ВариантКомплектации;
		ДокУпЛист.гф_Организация = ОрганизацияУпЛиста;
		ДокУпЛист.гф_Поставка = Объект.Ссылка;
		тчВариантКомплектации = строкаУпЛист["ВариантКомплектации"]["Товары"].Выгрузить();
		Для каждого стрТч Из тчВариантКомплектации Цикл
			нс = ДокУпЛист.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(нс, стрТч, "Номенклатура, Характеристика, Упаковка, КоличествоУпаковок");
			нс.ЭтоУпаковочныйЛист = Ложь;
			нс.Назначение = СлужебноеНазначение;
		КонецЦикла;
		
		Попытка
			ДокУпЛист.Записать(РежимЗаписиДокумента.Проведение);
			строкаУпЛист["IDКороба"] = ДокУпЛист.Ссылка;
		Исключение
			
			Попытка
				ДокУпЛист.Записать(РежимЗаписиДокумента.Запись);
				строкаУпЛист["IDКороба"] = ДокУпЛист.Ссылка;
			Исключение
				МенеджерЗаписи = РегистрыСведений.гф_ЗагруженныеСерийныеНомера.СоздатьМенеджерЗаписи();
				МенеджерЗаписи.Наименование = Выборка["Наименование"];
				МенеджерЗаписи.Прочитать();
				Если МенеджерЗаписи.Выбран() Тогда
					МенеджерЗаписи.Использован = Ложь;
					МенеджерЗаписи.Записать();
				КонецЕсли;
			КонецПопытки;
			
		КонецПопытки;
		
	КонецЦикла;	
	
	// ++ Галфинд_ДомнышеваКР_07_06_2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
	//Объект.гф_ПродукцияВКоробах.Загрузить(тзПродукцияВКоробах);
	Объект.гф_IDКоробов.Загрузить(тзIDКоробов); 
	ПараметрыЗаписи = Новый Структура;
	ПараметрыЗаписи.Вставить("РежимЗаписи", РежимЗаписиДокумента.Проведение);
	
	Записать(ПараметрыЗаписи); 
	//-- Галфинд_ДомнышеваКР_07_06_2023

КонецПроцедуры

&НаСервере
Функция ПолучитьСвободныеСерийныеНомера()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	гф_ЗагруженныеСерийныеНомера.Наименование КАК Наименование
	|ИЗ
	|	РегистрСведений.гф_ЗагруженныеСерийныеНомера КАК гф_ЗагруженныеСерийныеНомера
	|ГДЕ
	|	НЕ гф_ЗагруженныеСерийныеНомера.Использован
	|
	|УПОРЯДОЧИТЬ ПО
	|	Наименование";
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса;
	
КонецФункции 

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
// Галфинд_ДомнышеваКР_07_06_2023
&НаСервере
Функция УпаковочныеЛистыСозданыВсе(ВариантКомплектации, КоличествоКоробов)
	тзIDКоробов =  Объект.гф_IDКоробов.Выгрузить(); 
	Отбор = Новый Структура;
	Отбор.Вставить("ВариантКомплектации", ВариантКомплектации);
	
	МассивСтрокПоВарианту = тзIDКоробов.НайтиСтроки(Отбор);
	
	Если МассивСтрокПоВарианту.Количество() = КоличествоКоробов Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции// } #wortmann

// #wortmann {
// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee01247e7e0c5a
// Галфинд_ДомнышеваКР_07_06_2023
&НаКлиенте
Процедура гф_ОбновитьЗаголовокСтраницыIDКоробов()
КоличествоСтрок = Объект["гф_IDКоробов"].Количество();
	
	Элементы["гф_ГруппаIDКоробов"].Заголовок = 
	?(КоличествоСтрок = 0, 
	"ID Коробов",
	"ID Коробов ( "+ КоличествоСтрок + ")");
КонецПроцедуры// } #wortmann

#КонецОбласти