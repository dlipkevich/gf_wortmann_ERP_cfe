﻿#Область ОбработчикиСобытийФормы   
// #wortmann { 
// Параметры:
// Отказ, СтандартнаяОбработка 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Партнер") Тогда
		Партнер = Параметры.Партнер;		
		УстановитьОтборПоПартнеру();
	КонецЕсли;                                           
	
КонецПроцедуры
// } #wortmann 

#КонецОбласти

#Область ОбработчикиСобытийЭлементовСтраницыФормыОсновная 
// #wortmann {
// Замена запроса для динамического списка
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура ИсторияНаСервере()
	Список.ТекстЗапроса = ЗаменитьТекстЗапросаВДинамическомСписке();
КонецПроцедуры
// } #wortmann 

// #wortmann {
// Отбор формы списка по партеру,для команды
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура УстановитьОтборПоПартнеру()

ЭлементОтбора = Список.КомпоновщикНастроек.ФиксированныеНастройки.Отбор.
Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Контрагент");
ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
ЭлементОтбора.ПравоеЗначение = Партнер;		

КонецПроцедуры
// } #wortmann

// #wortmann { 
// Параметры:
//Команда 
// Обработка команды по созданию документа с видом операции установка лимита
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура СоздатьСнятиеЛимита(Команда) 
	
	ОперацияУстановкаЛимита = ПредопределенноеЗначение("Перечисление.гф_ВидыОперацийЛимита.СнятиеЛимита");
	ЭлементыОтбора = Новый Структура("ВидОперации", ОперацияУстановкаЛимита );
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЭлементыОтбора);
	ОткрытьФорму("Документ.гф_УстановкаСнятиеЛимита.Форма.гф_ФормаДокумента", ПараметрыФормы, ЭтотОбъект); 
	
КонецПроцедуры
// } #wortmann

 // #wortmann {
 // Параметры:
// Команда 
// Обработка команды по созданию документа с видом операции снятие лимита
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура СоздатьУстановкаЛимита(Команда)
	
	ОперацияУстановкаЛимита = ПредопределенноеЗначение("Перечисление.гф_ВидыОперацийЛимита.УстановкаЛимита");
	ЭлементыОтбора = Новый Структура("ВидОперации", ОперацияУстановкаЛимита );
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЭлементыОтбора);
	ОткрытьФорму("Документ.гф_УстановкаСнятиеЛимита.Форма.гф_ФормаДокумента", ПараметрыФормы, ЭтотОбъект); 
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// Параметры:
// Команда 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура История(Команда)
	ИсторияНаСервере();
КонецПроцедуры
// } #wortmann

// #wortmann {
// Замена запроса для динамического списка
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05  
// Возвращаемое значение:
// Запрос.Текс - текст запроса
&НаСервере
Функция ЗаменитьТекстЗапросаВДинамическомСписке() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_УстановкаСнятиеЛимита.Ссылка КАК Ссылка,
		|	гф_УстановкаСнятиеЛимита.Номер КАК Номер,
		|	гф_УстановкаСнятиеЛимита.Дата КАК Дата,
		|	гф_УстановкаСнятиеЛимита.Проведен КАК Проведен,
		|	гф_УстановкаСнятиеЛимита.ВидОперации КАК ВидОперации,
		|	гф_УстановкаСнятиеЛимита.Статус КАК Статус,
		|	гф_УстановкаСнятиеЛимита.Контрагент КАК Контрагент,
		|	гф_УстановкаСнятиеЛимита.Организация КАК Организация,
		|	гф_УстановкаСнятиеЛимита.ВидЛимита КАК ВидЛимита,
		|	гф_УстановкаСнятиеЛимита.Сумма КАК Сумма,
		|	гф_УстановкаСнятиеЛимита.Комментарий КАК Комментарий,
		|	гф_УстановкаСнятиеЛимита.Ответственный КАК Ответственный
		|ИЗ
		|	Документ.гф_УстановкаСнятиеЛимита КАК гф_УстановкаСнятиеЛимита";
	
	Возврат Запрос.Текст;
	
КонецФункции
// } #wortmann

#КонецОбласти